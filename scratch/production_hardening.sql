-- DEGLOOR ONE — production hardening
-- Run after schema.sql, secure_transactions.sql, secure_delivery.sql,
-- rls_order_policies.sql, secure_platform.sql, and jobs_services.sql.
--
-- What this script changes:
-- 1. Cart mutations become SECURITY DEFINER RPCs (no client read→write).
-- 2. Customers keep SELECT on their own carts; writes go through RPCs.
-- 3. Duplicate cart lines are merged and uniquely constrained.
-- 4. Delivery location history + 15s throttle + 48h retention.
-- 5. Anonymous analytics inserts are removed.
-- 6. Customers cannot INSERT orders directly (RPCs only).
-- 7. Unread notification count is a single SQL count, not a full table read.

-- ==========================================
-- Role helpers (existing values stay lowercase)
-- customer | admin in users.role
-- BUSINESS_OWNER = owns a businesses row
-- DELIVERY_PARTNER = has a delivery_partners row
-- ==========================================

CREATE OR REPLACE FUNCTION is_business_owner()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM businesses WHERE owner_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION is_delivery_partner()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM delivery_partners WHERE user_id = auth.uid()
  );
$$;

REVOKE ALL ON FUNCTION is_business_owner() FROM PUBLIC;
REVOKE ALL ON FUNCTION is_delivery_partner() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION is_business_owner() TO authenticated;
GRANT EXECUTE ON FUNCTION is_delivery_partner() TO authenticated;

-- ==========================================
-- Cart uniqueness
-- ==========================================

WITH ranked AS (
  SELECT
    id,
    FIRST_VALUE(id) OVER (
      PARTITION BY cart_id, product_id
      ORDER BY created_at, id
    ) AS keep_id,
    SUM(quantity) OVER (PARTITION BY cart_id, product_id) AS total_qty
  FROM cart_items
)
UPDATE cart_items ci
SET quantity = ranked.total_qty
FROM ranked
WHERE ci.id = ranked.keep_id
  AND ci.quantity IS DISTINCT FROM ranked.total_qty;

DELETE FROM cart_items ci
WHERE EXISTS (
  SELECT 1
  FROM cart_items keep
  WHERE keep.cart_id = ci.cart_id
    AND keep.product_id = ci.product_id
    AND keep.id < ci.id
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_cart_items_cart_product
  ON cart_items (cart_id, product_id);
CREATE INDEX IF NOT EXISTS idx_carts_user_id
  ON carts (user_id);

-- ==========================================
-- Cart RLS — read own rows; mutate via RPC
-- ==========================================

DROP POLICY IF EXISTS "Users manage own carts" ON carts;
DROP POLICY IF EXISTS "Users read own carts" ON carts;
CREATE POLICY "Users read own carts" ON carts
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users read own cart items" ON cart_items;
CREATE POLICY "Users read own cart items" ON cart_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM carts
      WHERE id = cart_items.cart_id AND user_id = auth.uid()
    )
  );

-- Customers must not create orders from the client.
DROP POLICY IF EXISTS "Users insert own orders" ON orders;

-- Analytics: signed-in users only, own user_id.
DROP POLICY IF EXISTS "Anyone can insert analytics" ON business_analytics;
CREATE POLICY "Users insert own analytics" ON business_analytics
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- Cart RPCs
-- ==========================================

CREATE OR REPLACE FUNCTION add_to_cart(
  p_product_id UUID,
  p_quantity INT DEFAULT 1,
  p_replace_other_business BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_business_id UUID;
  v_available BOOLEAN;
  v_track BOOLEAN;
  v_stock INT;
  v_verified BOOLEAN;
  v_other UUID;
  v_cart_id UUID;
  v_item_id UUID;
  v_existing INT;
  v_new_qty INT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'CART_UNAUTHORIZED';
  END IF;
  IF p_quantity IS NULL OR p_quantity < 1 OR p_quantity > 99 THEN
    RAISE EXCEPTION 'CART_INVALID_QTY';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext(auth.uid()::text));

  SELECT p.business_id, COALESCE(p.is_available, TRUE), COALESCE(p.track_inventory, FALSE),
         COALESCE(p.stock_quantity, 0), COALESCE(b.is_verified, FALSE)
  INTO v_business_id, v_available, v_track, v_stock, v_verified
  FROM products p
  JOIN businesses b ON b.id = p.business_id
  WHERE p.id = p_product_id
  FOR UPDATE OF p;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'CART_PRODUCT';
  END IF;
  IF v_verified IS FALSE THEN
    RAISE EXCEPTION 'CART_PRODUCT';
  END IF;
  IF v_available IS FALSE THEN
    RAISE EXCEPTION 'CART_UNAVAILABLE';
  END IF;

  SELECT id INTO v_other
  FROM carts
  WHERE user_id = auth.uid() AND business_id <> v_business_id
  LIMIT 1;

  IF v_other IS NOT NULL THEN
    IF NOT COALESCE(p_replace_other_business, FALSE) THEN
      RETURN jsonb_build_object('ok', FALSE, 'code', 'needs_replacement');
    END IF;
    DELETE FROM carts
    WHERE user_id = auth.uid() AND business_id <> v_business_id;
  END IF;

  SELECT id INTO v_cart_id
  FROM carts
  WHERE user_id = auth.uid() AND business_id = v_business_id
  FOR UPDATE;

  IF v_cart_id IS NULL THEN
    INSERT INTO carts (user_id, business_id)
    VALUES (auth.uid(), v_business_id)
    RETURNING id INTO v_cart_id;
  END IF;

  SELECT id, quantity INTO v_item_id, v_existing
  FROM cart_items
  WHERE cart_id = v_cart_id AND product_id = p_product_id
  FOR UPDATE;

  v_new_qty := COALESCE(v_existing, 0) + p_quantity;
  IF v_new_qty > 99 THEN
    RAISE EXCEPTION 'CART_INVALID_QTY';
  END IF;
  IF v_track AND v_stock < v_new_qty THEN
    RAISE EXCEPTION 'CART_STOCK';
  END IF;

  IF v_item_id IS NULL THEN
    INSERT INTO cart_items (cart_id, product_id, quantity)
    VALUES (v_cart_id, p_product_id, p_quantity)
    RETURNING id INTO v_item_id;
    v_new_qty := p_quantity;
  ELSE
    UPDATE cart_items SET quantity = v_new_qty WHERE id = v_item_id;
  END IF;

  RETURN jsonb_build_object(
    'ok', TRUE,
    'cart_id', v_cart_id,
    'item_id', v_item_id,
    'quantity', v_new_qty
  );
END;
$$;

CREATE OR REPLACE FUNCTION update_cart_quantity(
  p_item_id UUID,
  p_quantity INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_cart_id UUID;
  v_product_id UUID;
  v_user UUID;
  v_track BOOLEAN;
  v_stock INT;
  v_available BOOLEAN;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'CART_UNAUTHORIZED';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext(auth.uid()::text));

  SELECT ci.cart_id, ci.product_id, c.user_id
  INTO v_cart_id, v_product_id, v_user
  FROM cart_items ci
  JOIN carts c ON c.id = ci.cart_id
  WHERE ci.id = p_item_id
  FOR UPDATE OF ci;

  IF NOT FOUND OR v_user <> auth.uid() THEN
    RAISE EXCEPTION 'CART_UNAUTHORIZED';
  END IF;

  IF p_quantity IS NULL OR p_quantity < 1 THEN
    DELETE FROM cart_items WHERE id = p_item_id;
    IF NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = v_cart_id) THEN
      DELETE FROM carts WHERE id = v_cart_id;
    END IF;
    RETURN;
  END IF;
  IF p_quantity > 99 THEN
    RAISE EXCEPTION 'CART_INVALID_QTY';
  END IF;

  SELECT COALESCE(is_available, TRUE), COALESCE(track_inventory, FALSE),
         COALESCE(stock_quantity, 0)
  INTO v_available, v_track, v_stock
  FROM products
  WHERE id = v_product_id
  FOR UPDATE;

  IF NOT FOUND OR v_available IS FALSE THEN
    RAISE EXCEPTION 'CART_UNAVAILABLE';
  END IF;
  IF v_track AND v_stock < p_quantity THEN
    RAISE EXCEPTION 'CART_STOCK';
  END IF;

  UPDATE cart_items SET quantity = p_quantity WHERE id = p_item_id;
END;
$$;

CREATE OR REPLACE FUNCTION remove_from_cart(p_item_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM update_cart_quantity(p_item_id, 0);
END;
$$;

CREATE OR REPLACE FUNCTION clear_cart()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'CART_UNAUTHORIZED';
  END IF;
  DELETE FROM carts WHERE user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION add_to_cart(UUID, INT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION update_cart_quantity(UUID, INT) FROM PUBLIC;
REVOKE ALL ON FUNCTION remove_from_cart(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION clear_cart() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION add_to_cart(UUID, INT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION update_cart_quantity(UUID, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION remove_from_cart(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION clear_cart() TO authenticated;

-- ==========================================
-- Delivery partner location history
-- ==========================================

CREATE TABLE IF NOT EXISTS delivery_partner_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL REFERENCES delivery_partners(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  accuracy DOUBLE PRECISION,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE delivery_partner_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins manage location history" ON delivery_partner_locations;
CREATE POLICY "Admins manage location history" ON delivery_partner_locations
  FOR ALL
  USING (is_admin());

DROP POLICY IF EXISTS "Partners read own location history" ON delivery_partner_locations;
CREATE POLICY "Partners read own location history" ON delivery_partner_locations
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM delivery_partners
      WHERE id = delivery_partner_locations.partner_id
        AND user_id = auth.uid()
    )
  );

CREATE INDEX IF NOT EXISTS idx_delivery_partner_locations_partner_recorded
  ON delivery_partner_locations (partner_id, recorded_at DESC);

DROP FUNCTION IF EXISTS update_delivery_location(DOUBLE PRECISION, DOUBLE PRECISION);
CREATE OR REPLACE FUNCTION update_delivery_location(
  p_latitude DOUBLE PRECISION,
  p_longitude DOUBLE PRECISION,
  p_accuracy DOUBLE PRECISION DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_partner_id UUID;
  v_last TIMESTAMPTZ;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not a delivery partner';
  END IF;
  IF p_latitude IS NULL OR p_longitude IS NULL
     OR p_latitude < -90 OR p_latitude > 90
     OR p_longitude < -180 OR p_longitude > 180 THEN
    RAISE EXCEPTION 'Invalid coordinates';
  END IF;

  SELECT id INTO v_partner_id
  FROM delivery_partners
  WHERE user_id = auth.uid()
  FOR UPDATE;

  IF v_partner_id IS NULL THEN
    RAISE EXCEPTION 'Not a delivery partner';
  END IF;

  SELECT recorded_at INTO v_last
  FROM delivery_partner_locations
  WHERE partner_id = v_partner_id
  ORDER BY recorded_at DESC
  LIMIT 1;

  IF v_last IS NOT NULL AND v_last > NOW() - INTERVAL '15 seconds' THEN
    RETURN;
  END IF;

  UPDATE delivery_partners
  SET current_latitude = p_latitude,
      current_longitude = p_longitude
  WHERE id = v_partner_id;

  INSERT INTO delivery_partner_locations (
    partner_id, latitude, longitude, accuracy
  ) VALUES (
    v_partner_id, p_latitude, p_longitude, p_accuracy
  );

  DELETE FROM delivery_partner_locations
  WHERE partner_id = v_partner_id
    AND recorded_at < NOW() - INTERVAL '48 hours';
END;
$$;

GRANT EXECUTE ON FUNCTION update_delivery_location(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION)
  TO authenticated;

-- ==========================================
-- Notifications — unread count only
-- ==========================================

CREATE OR REPLACE FUNCTION unread_notification_count()
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COUNT(*)::INT
  FROM notifications
  WHERE user_id = auth.uid() AND COALESCE(is_read, FALSE) = FALSE;
$$;

REVOKE ALL ON FUNCTION unread_notification_count() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION unread_notification_count() TO authenticated;
