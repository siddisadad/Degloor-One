-- DEGLOOR ONE - Secure delivery claim + OTP verification
-- Run in the Supabase SQL editor after schema.sql and secure_transactions.sql.

-- Only one active assignment per order (delivered rows may remain as history).
CREATE UNIQUE INDEX IF NOT EXISTS idx_delivery_assignments_one_active
    ON delivery_assignments (order_id)
    WHERE status <> 'delivered';

-- Generate a 4-digit OTP whenever one is missing.
CREATE OR REPLACE FUNCTION ensure_delivery_otp()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    IF NEW.delivery_otp IS NULL OR NEW.delivery_otp = '' THEN
        NEW.delivery_otp := lpad((floor(random() * 10000))::int::text, 4, '0');
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_orders_ensure_delivery_otp ON orders;
CREATE TRIGGER trg_orders_ensure_delivery_otp
    BEFORE INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION ensure_delivery_otp();

-- Hide the OTP from PostgREST select=* so partners cannot read it.
REVOKE SELECT (delivery_otp) ON orders FROM PUBLIC;
REVOKE SELECT (delivery_otp) ON orders FROM anon;
REVOKE SELECT (delivery_otp) ON orders FROM authenticated;
REVOKE UPDATE (delivery_otp) ON orders FROM PUBLIC;
REVOKE UPDATE (delivery_otp) ON orders FROM anon;
REVOKE UPDATE (delivery_otp) ON orders FROM authenticated;

-- Verified partners can browse ready jobs and see orders they already claimed.
DROP POLICY IF EXISTS "Partners read ready orders" ON orders;
CREATE POLICY "Partners read ready orders" ON orders FOR SELECT USING (
    status = 'ready'
    AND EXISTS (
        SELECT 1 FROM delivery_partners
        WHERE user_id = auth.uid() AND is_verified = TRUE
    )
);

DROP POLICY IF EXISTS "Partners read assigned orders" ON orders;
CREATE POLICY "Partners read assigned orders" ON orders FOR SELECT USING (
    EXISTS (
        SELECT 1
        FROM delivery_assignments da
        JOIN delivery_partners dp ON dp.id = da.delivery_partner_id
        WHERE da.order_id = orders.id
          AND dp.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Partners read own row" ON delivery_partners;
CREATE POLICY "Partners read own row" ON delivery_partners FOR SELECT
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Partners insert own row" ON delivery_partners;
CREATE POLICY "Partners insert own row" ON delivery_partners FOR INSERT
    WITH CHECK (user_id = auth.uid() AND COALESCE(is_verified, FALSE) = FALSE);

DROP POLICY IF EXISTS "Partners update own availability" ON delivery_partners;
CREATE POLICY "Partners update own availability" ON delivery_partners FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (
        user_id = auth.uid()
        AND is_verified = (SELECT p.is_verified FROM delivery_partners p WHERE p.id = delivery_partners.id)
    );

DROP POLICY IF EXISTS "Partners read own assignments" ON delivery_assignments;
CREATE POLICY "Partners read own assignments" ON delivery_assignments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM delivery_partners
            WHERE id = delivery_assignments.delivery_partner_id
              AND user_id = auth.uid()
        )
    );

CREATE OR REPLACE FUNCTION accept_delivery_order(p_order_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_partner_id UUID;
    v_assignment_id UUID;
    v_updated INT;
BEGIN
    SELECT id INTO v_partner_id
    FROM delivery_partners
    WHERE user_id = auth.uid() AND is_verified = TRUE
    LIMIT 1;

    IF v_partner_id IS NULL THEN
        RAISE EXCEPTION 'Not a verified delivery partner';
    END IF;

    IF EXISTS (
        SELECT 1 FROM delivery_assignments
        WHERE delivery_partner_id = v_partner_id AND status <> 'delivered'
    ) THEN
        RAISE EXCEPTION 'You already have an active delivery';
    END IF;

    UPDATE orders
    SET status = 'shipping'
    WHERE id = p_order_id AND status = 'ready';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN
        RAISE EXCEPTION 'Order is no longer available';
    END IF;

    INSERT INTO delivery_assignments (order_id, delivery_partner_id, status)
    VALUES (p_order_id, v_partner_id, 'assigned')
    RETURNING id INTO v_assignment_id;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (p_order_id, 'shipping', 'Order accepted by delivery partner.');

    RETURN v_assignment_id;
END;
$$;

CREATE OR REPLACE FUNCTION confirm_delivery_pickup(p_assignment_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order_id UUID;
    v_updated INT;
BEGIN
    UPDATE delivery_assignments da
    SET status = 'picked_up'
    FROM delivery_partners dp
    WHERE da.id = p_assignment_id
      AND da.status = 'assigned'
      AND da.delivery_partner_id = dp.id
      AND dp.user_id = auth.uid()
    RETURNING da.order_id INTO v_order_id;
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN
        RAISE EXCEPTION 'Pickup is not allowed for this assignment';
    END IF;

    UPDATE orders SET status = 'out_for_delivery' WHERE id = v_order_id;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (v_order_id, 'out_for_delivery', 'Order picked up by delivery partner.');
END;
$$;

CREATE OR REPLACE FUNCTION confirm_delivery_with_otp(p_order_id UUID, p_otp TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_stored_otp TEXT;
    v_status TEXT;
    v_business_id UUID;
    v_is_owner BOOLEAN := FALSE;
    v_is_assignee BOOLEAN := FALSE;
    v_assignment_id UUID;
    v_assignment_status TEXT;
BEGIN
    IF p_otp IS NULL OR length(btrim(p_otp)) <> 4 THEN
        RAISE EXCEPTION 'Invalid OTP';
    END IF;

    SELECT delivery_otp, status, business_id
    INTO v_stored_otp, v_status, v_business_id
    FROM orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    IF v_status IN ('delivered', 'cancelled') THEN
        RAISE EXCEPTION 'Order is no longer active';
    END IF;

    IF v_stored_otp IS NULL OR v_stored_otp <> btrim(p_otp) THEN
        RAISE EXCEPTION 'Invalid OTP';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM businesses
        WHERE id = v_business_id AND owner_id = auth.uid()
    ) INTO v_is_owner;

    SELECT da.id, da.status
    INTO v_assignment_id, v_assignment_status
    FROM delivery_assignments da
    JOIN delivery_partners dp ON dp.id = da.delivery_partner_id
    WHERE da.order_id = p_order_id
      AND da.status <> 'delivered'
      AND dp.user_id = auth.uid()
    LIMIT 1;

    v_is_assignee := v_assignment_id IS NOT NULL;

    IF NOT v_is_owner AND NOT v_is_assignee THEN
        RAISE EXCEPTION 'Not allowed to confirm this delivery';
    END IF;

    IF v_is_assignee AND v_assignment_status <> 'picked_up' THEN
        RAISE EXCEPTION 'Confirm pickup before verifying delivery';
    END IF;

    IF v_is_owner AND NOT v_is_assignee AND v_status <> 'ready' THEN
        RAISE EXCEPTION 'Counter delivery is only allowed while the order is ready';
    END IF;

    UPDATE orders SET status = 'delivered' WHERE id = p_order_id;

    IF v_assignment_id IS NOT NULL THEN
        UPDATE delivery_assignments SET status = 'delivered' WHERE id = v_assignment_id;
    END IF;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (p_order_id, 'delivered', 'Order delivered after server-side OTP verification.');
END;
$$;

CREATE OR REPLACE FUNCTION get_my_delivery_otp(p_order_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_otp TEXT;
    v_user_id UUID;
    v_business_id UUID;
    v_status TEXT;
BEGIN
    SELECT delivery_otp, user_id, business_id, status
    INTO v_otp, v_user_id, v_business_id, v_status
    FROM orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    IF auth.uid() IS DISTINCT FROM v_user_id
       AND NOT EXISTS (
           SELECT 1 FROM businesses
           WHERE id = v_business_id AND owner_id = auth.uid()
       ) THEN
        RAISE EXCEPTION 'Not allowed to view this OTP';
    END IF;

    IF v_status IN ('delivered', 'cancelled') THEN
        RETURN NULL;
    END IF;

    IF v_otp IS NULL OR v_otp = '' THEN
        v_otp := lpad((floor(random() * 10000))::int::text, 4, '0');
        UPDATE orders SET delivery_otp = v_otp WHERE id = p_order_id;
    END IF;

    RETURN v_otp;
END;
$$;

GRANT EXECUTE ON FUNCTION accept_delivery_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION confirm_delivery_pickup(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION confirm_delivery_with_otp(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_my_delivery_otp(UUID) TO authenticated;
