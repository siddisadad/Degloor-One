-- DEGLOOR ONE — platform hardening
-- Run after schema.sql, secure_transactions.sql, secure_delivery.sql,
-- and rls_order_policies.sql.

-- ==========================================
-- Admin / role helpers
-- ==========================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION current_user_role()
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT role FROM users WHERE id = auth.uid();
$$;

REVOKE ALL ON FUNCTION is_admin() FROM PUBLIC;
REVOKE ALL ON FUNCTION current_user_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION current_user_role() TO authenticated;

-- Customers cannot self-promote. Admins keep full control via is_admin().
DROP POLICY IF EXISTS "Users manage own profile" ON users;
CREATE POLICY "Users manage own profile" ON users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    AND role = (SELECT u.role FROM users u WHERE u.id = auth.uid())
    AND (role <> 'admin' OR is_admin())
  );

-- ==========================================
-- Order RLS — customers cannot write orders / line items / history
-- ==========================================

DROP POLICY IF EXISTS "Users insert own orders" ON orders;

DROP POLICY IF EXISTS "Users manage own order items" ON order_items;
CREATE POLICY "Users read own order items" ON order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE id = order_items.order_id AND user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners read order items" ON order_items;
CREATE POLICY "Owners read order items" ON order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM orders o
      JOIN businesses b ON b.id = o.business_id
      WHERE o.id = order_items.order_id AND b.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users manage own order status history" ON order_status_history;
DROP POLICY IF EXISTS "Users read own order history" ON order_status_history;
CREATE POLICY "Users read own order history" ON order_status_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE id = order_status_history.order_id AND user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners read order history" ON order_status_history;
CREATE POLICY "Owners read order history" ON order_status_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM orders o
      JOIN businesses b ON b.id = o.business_id
      WHERE o.id = order_status_history.order_id AND b.owner_id = auth.uid()
    )
  );

-- Owners must use update_order_status / cancel_order / OTP RPCs.
DROP POLICY IF EXISTS "Owners update orders for their business" ON orders;

-- Notifications: customers mark read only. Inserts go through notify_user().
DROP POLICY IF EXISTS "Users update own notifications" ON notifications;
CREATE POLICY "Users update own notifications" ON notifications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- Storage — product-images bucket
-- Path convention: products/{business_id}/… or businesses/{business_id}/…
-- ==========================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

DROP POLICY IF EXISTS "Public read product images" ON storage.objects;
CREATE POLICY "Public read product images" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Owners upload product images" ON storage.objects;
CREATE POLICY "Owners upload product images" ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'product-images'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] IN ('products', 'businesses')
    AND EXISTS (
      SELECT 1 FROM businesses
      WHERE id::text = (storage.foldername(name))[2]
        AND owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners update product images" ON storage.objects;
CREATE POLICY "Owners update product images" ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'product-images'
    AND (storage.foldername(name))[1] IN ('products', 'businesses')
    AND EXISTS (
      SELECT 1 FROM businesses
      WHERE id::text = (storage.foldername(name))[2]
        AND owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners delete product images" ON storage.objects;
CREATE POLICY "Owners delete product images" ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'product-images'
    AND (storage.foldername(name))[1] IN ('products', 'businesses')
    AND EXISTS (
      SELECT 1 FROM businesses
      WHERE id::text = (storage.foldername(name))[2]
        AND owner_id = auth.uid()
    )
  );

-- ==========================================
-- Notifications (server-side only)
-- ==========================================

CREATE OR REPLACE FUNCTION notify_user(
    p_user_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'general'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_user_id IS NULL THEN
    RETURN;
  END IF;
  INSERT INTO notifications (user_id, title, message, type, is_read)
  VALUES (p_user_id, p_title, p_message, COALESCE(p_type, 'general'), FALSE);
END;
$$;

REVOKE ALL ON FUNCTION notify_user(UUID, TEXT, TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION notify_user(UUID, TEXT, TEXT, TEXT) FROM anon;
REVOKE ALL ON FUNCTION notify_user(UUID, TEXT, TEXT, TEXT) FROM authenticated;

-- ==========================================
-- Checkout — server-side pricing, stock, history
-- ==========================================

CREATE OR REPLACE FUNCTION place_order(
    p_business_id UUID,
    p_total_amount FLOAT,
    p_delivery_address_id UUID,
    p_payment_method TEXT,
    p_items JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id UUID;
    v_quantity INT;
    v_unit_price DOUBLE PRECISION;
    v_subtotal DOUBLE PRECISION := 0;
    v_delivery_fee DOUBLE PRECISION := 0;
    v_track BOOLEAN;
    v_available BOOLEAN;
    v_updated INT;
    v_owner_id UUID;
    v_short TEXT;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'Cart is empty';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM addresses
        WHERE id = p_delivery_address_id AND user_id = auth.uid()
    ) THEN
        RAISE EXCEPTION 'Delivery address not found';
    END IF;

    SELECT owner_id INTO v_owner_id
    FROM businesses
    WHERE id = p_business_id AND is_verified = TRUE;
    IF v_owner_id IS NULL THEN
        RAISE EXCEPTION 'Business is not available';
    END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := COALESCE((v_item->>'quantity')::INT, 0);
        IF v_quantity <= 0 THEN
            RAISE EXCEPTION 'Invalid quantity for product %', v_product_id;
        END IF;

        SELECT price, track_inventory, is_available
        INTO v_unit_price, v_track, v_available
        FROM products
        WHERE id = v_product_id AND business_id = p_business_id
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product % is not sold by this business', v_product_id;
        END IF;
        IF COALESCE(v_available, TRUE) IS FALSE THEN
            RAISE EXCEPTION 'Product % is unavailable', v_product_id;
        END IF;

        v_subtotal := v_subtotal + (v_unit_price * v_quantity);

        IF COALESCE(v_track, FALSE) THEN
            UPDATE products
            SET stock_quantity = stock_quantity - v_quantity
            WHERE id = v_product_id
              AND business_id = p_business_id
              AND stock_quantity >= v_quantity;
            GET DIAGNOSTICS v_updated = ROW_COUNT;
            IF v_updated = 0 THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_product_id;
            END IF;
        END IF;
    END LOOP;

    v_delivery_fee := COALESCE(
        calculate_delivery_fee(p_business_id, p_delivery_address_id),
        0
    );

    INSERT INTO orders (
        user_id,
        business_id,
        total_amount,
        delivery_address_id,
        delivery_fee,
        payment_method,
        status,
        payment_status
    ) VALUES (
        auth.uid(),
        p_business_id,
        v_subtotal + v_delivery_fee,
        p_delivery_address_id,
        v_delivery_fee,
        COALESCE(p_payment_method, 'COD'),
        'pending',
        'unpaid'
    ) RETURNING id INTO v_order_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INT;
        SELECT price INTO v_unit_price
        FROM products
        WHERE id = v_product_id;

        INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
        VALUES (v_order_id, v_product_id, v_quantity, v_unit_price);
    END LOOP;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (v_order_id, 'pending', 'Order placed');

    DELETE FROM cart_items
    WHERE cart_id IN (
        SELECT id FROM carts
        WHERE user_id = auth.uid() AND business_id = p_business_id
    );
    DELETE FROM carts
    WHERE user_id = auth.uid() AND business_id = p_business_id;

    v_short := substring(v_order_id::text, 1, 8);
    PERFORM notify_user(
        v_owner_id,
        'New order',
        'Order #' || v_short || ' is waiting for confirmation.',
        'order_status'
    );
    PERFORM notify_user(
        auth.uid(),
        'Order placed',
        'Order #' || v_short || ' was placed and is pending confirmation.',
        'order_status'
    );

    RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION place_order(UUID, FLOAT, UUID, TEXT, JSONB) TO authenticated;

-- ==========================================
-- Order state machine + cancellation
-- ==========================================

CREATE OR REPLACE FUNCTION restore_order_stock(p_order_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_item RECORD;
BEGIN
    FOR v_item IN
        SELECT oi.product_id, oi.quantity, p.track_inventory
        FROM order_items oi
        JOIN products p ON p.id = oi.product_id
        WHERE oi.order_id = p_order_id
    LOOP
        IF COALESCE(v_item.track_inventory, FALSE) THEN
            UPDATE products
            SET stock_quantity = stock_quantity + v_item.quantity
            WHERE id = v_item.product_id;
        END IF;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION cancel_order(p_order_id UUID, p_reason TEXT DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_business_id UUID;
    v_status TEXT;
    v_owner_id UUID;
    v_is_owner BOOLEAN := FALSE;
    v_is_customer BOOLEAN := FALSE;
    v_short TEXT;
BEGIN
    SELECT user_id, business_id, status
    INTO v_user_id, v_business_id, v_status
    FROM orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    SELECT owner_id INTO v_owner_id FROM businesses WHERE id = v_business_id;
    v_is_owner := v_owner_id IS NOT DISTINCT FROM auth.uid();
    v_is_customer := v_user_id IS NOT DISTINCT FROM auth.uid();

    IF NOT v_is_owner AND NOT v_is_customer AND NOT is_admin() THEN
        RAISE EXCEPTION 'Not allowed to cancel this order';
    END IF;

    IF v_status IN ('delivered', 'cancelled') THEN
        RAISE EXCEPTION 'Order cannot be cancelled';
    END IF;

    IF v_is_customer AND NOT v_is_owner AND v_status <> 'pending' THEN
        RAISE EXCEPTION 'Customers can cancel only while the order is pending';
    END IF;

    IF v_is_owner AND v_status IN ('shipping', 'out_for_delivery') THEN
        RAISE EXCEPTION 'Cannot cancel after a rider has been assigned';
    END IF;

    PERFORM restore_order_stock(p_order_id);

    UPDATE orders SET status = 'cancelled' WHERE id = p_order_id;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (
        p_order_id,
        'cancelled',
        COALESCE(NULLIF(btrim(p_reason), ''), 'Order cancelled')
    );

    v_short := substring(p_order_id::text, 1, 8);
    PERFORM notify_user(
        v_user_id,
        'Order cancelled',
        'Order #' || v_short || ' was cancelled.',
        'order_status'
    );
    IF v_owner_id IS NOT NULL AND v_owner_id IS DISTINCT FROM v_user_id THEN
        PERFORM notify_user(
            v_owner_id,
            'Order cancelled',
            'Order #' || v_short || ' was cancelled.',
            'order_status'
        );
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION update_order_status(p_order_id UUID, p_status TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_status TEXT;
    v_business_id UUID;
    v_user_id UUID;
    v_next TEXT;
    v_short TEXT;
BEGIN
    v_next := lower(btrim(p_status));

    SELECT status, business_id, user_id
    INTO v_status, v_business_id, v_user_id
    FROM orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM businesses
        WHERE id = v_business_id AND owner_id = auth.uid()
    ) AND NOT is_admin() THEN
        RAISE EXCEPTION 'Not allowed to update this order';
    END IF;

    IF v_next = 'cancelled' THEN
        PERFORM cancel_order(p_order_id, 'Cancelled by shop');
        RETURN;
    END IF;

    IF v_next = 'delivered' THEN
        RAISE EXCEPTION 'Use confirm_delivery_with_otp to mark delivered';
    END IF;

    IF NOT (
        (v_status = 'pending' AND v_next = 'accepted')
        OR (v_status = 'accepted' AND v_next = 'ready')
    ) THEN
        RAISE EXCEPTION 'Invalid status transition from % to %', v_status, v_next;
    END IF;

    UPDATE orders SET status = v_next WHERE id = p_order_id;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (p_order_id, v_next, 'Order status updated by business owner.');

    v_short := substring(p_order_id::text, 1, 8);
    PERFORM notify_user(
        v_user_id,
        'Order updated',
        'Your order #' || v_short || ' is now ' || replace(v_next, '_', ' ') || '.',
        'order_status'
    );
END;
$$;

GRANT EXECUTE ON FUNCTION cancel_order(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION update_order_status(UUID, TEXT) TO authenticated;

-- ==========================================
-- Delivery location (validated)
-- ==========================================

CREATE OR REPLACE FUNCTION update_delivery_location(
    p_latitude DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_updated INT;
BEGIN
    IF p_latitude IS NULL OR p_longitude IS NULL
       OR p_latitude < -90 OR p_latitude > 90
       OR p_longitude < -180 OR p_longitude > 180 THEN
        RAISE EXCEPTION 'Invalid coordinates';
    END IF;

    UPDATE delivery_partners
    SET current_latitude = p_latitude,
        current_longitude = p_longitude
    WHERE user_id = auth.uid();
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN
        RAISE EXCEPTION 'Not a delivery partner';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION update_delivery_location(DOUBLE PRECISION, DOUBLE PRECISION) TO authenticated;

-- Pickup may only move assigned -> picked_up and order -> out_for_delivery.
CREATE OR REPLACE FUNCTION confirm_delivery_pickup(p_assignment_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order_id UUID;
    v_status TEXT;
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

    SELECT status INTO v_status FROM orders WHERE id = v_order_id FOR UPDATE;
    IF v_status NOT IN ('shipping', 'ready') THEN
        RAISE EXCEPTION 'Order is not ready for pickup';
    END IF;

    UPDATE orders SET status = 'out_for_delivery' WHERE id = v_order_id;

    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (v_order_id, 'out_for_delivery', 'Order picked up by delivery partner.');
END;
$$;

-- ==========================================
-- Query indexes
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_orders_user_created
    ON orders (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_business_created
    ON orders (business_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status
    ON orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_status_ready
    ON orders (status)
    WHERE status = 'ready';
CREATE INDEX IF NOT EXISTS idx_notifications_user_created
    ON notifications (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_products_business_available
    ON products (business_id)
    WHERE is_available = TRUE;
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_partner_status
    ON delivery_assignments (delivery_partner_id, status);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_created
    ON order_status_history (order_id, created_at DESC);
