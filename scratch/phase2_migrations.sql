-- DEGLOOR ONE - PHASE 2 COMMERCE MIGRATIONS

-- 1. Public Visibility for Products & Categories
DROP POLICY IF EXISTS "Public read product_categories" ON product_categories;
CREATE POLICY "Public read product_categories" ON product_categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read products" ON products;
CREATE POLICY "Public read products" ON products FOR SELECT USING (is_available = true);

-- 2. Cart Management Hardening
-- Carts policy is already present in schema.sql but ensuring it's robust
DROP POLICY IF EXISTS "Users manage own carts" ON carts;
CREATE POLICY "Users manage own carts" ON carts FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage own cart items" ON cart_items;
CREATE POLICY "Users manage own cart items" ON cart_items FOR ALL USING (
    EXISTS (SELECT 1 FROM carts WHERE id = cart_items.cart_id AND user_id = auth.uid())
);

-- 3. Storage Configuration (Supabase Storage)
-- Ensure buckets exist (usually done via UI or API, but documenting here)
-- Bucket: product-images (Public)
-- Bucket: business-photos (Public)

-- Storage Policies for product-images
-- Note: Requires storage schema extension which is standard in Supabase
DO $$
BEGIN
    -- Policy for public viewing
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public Access' AND tablename = 'objects') THEN
        -- Standard Supabase Storage policy format
        NULL; -- Documentation only, actual creation often requires specific storage schema access
    END IF;
END $$;

-- 4. Order Constraints
-- Ensure orders can only be placed with 'pending' status by users
DROP POLICY IF EXISTS "Users insert own orders" ON orders;
CREATE POLICY "Users insert own orders" ON orders FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND status = 'pending'
    AND payment_status = 'unpaid'
);

-- 5. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_products_business_id ON products(business_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_business_id ON orders(business_id);
