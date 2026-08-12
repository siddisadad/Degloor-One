-- ==========================================
-- DEGLOOR ONE - SUPABASE SCHEMA
-- ==========================================

-- Enable PostGIS extension for spatial queries
CREATE EXTENSION IF NOT EXISTS postgis;
-- Enable pgcrypto for password hashing in seed scripts
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. DROP TABLES (Ordered for dependencies)
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS business_analytics CASCADE;
DROP TABLE IF EXISTS business_hours CASCADE;
DROP TABLE IF EXISTS delivery_assignments CASCADE;
DROP TABLE IF EXISTS delivery_partners CASCADE;
DROP TABLE IF EXISTS service_requests CASCADE;
DROP TABLE IF EXISTS service_providers CASCADE;
DROP TABLE IF EXISTS service_categories CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS order_status_history CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS businesses CASCADE;
DROP TABLE IF EXISTS business_categories CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==========================================
-- CORE TABLES
-- ==========================================

-- Cities Table
CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    state TEXT,
    district TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    role TEXT DEFAULT 'customer',
    phone_number TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Addresses Table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT,
    address_text TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business Categories Table
CREATE TABLE business_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    icon_name TEXT,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Businesses Table
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    owner_name TEXT,
    description TEXT,
    category_id UUID REFERENCES business_categories(id) ON DELETE SET NULL,
    city_id UUID REFERENCES cities(id) ON DELETE SET NULL,
    address_text TEXT,
    whatsapp_number TEXT,
    phone_number TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location GEOGRAPHY(POINT, 4326),
    discovery_radius DOUBLE PRECISION,
    rating DOUBLE PRECISION DEFAULT 0.0,
    is_open BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(owner_id, name)
);

-- Product Categories Table
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(business_id, name)
);

-- Products Table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    category_id UUID REFERENCES product_categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    price DOUBLE PRECISION,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    stock_quantity INTEGER DEFAULT 0,
    track_inventory BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(business_id, name)
);

-- Carts Table
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, business_id)
);

-- Cart Items Table
CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID REFERENCES carts(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders Table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    total_amount DOUBLE PRECISION NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    payment_status TEXT NOT NULL DEFAULT 'unpaid',
    delivery_address_id UUID REFERENCES addresses(id),
    delivery_fee DOUBLE PRECISION DEFAULT 0.0,
    payment_method TEXT,
    delivery_otp TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order Status History Table
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order Items Table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    price_at_purchase DOUBLE PRECISION NOT NULL
);

-- Reviews Table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, business_id) -- One review per business per user
);

-- Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service Categories Table
CREATE TABLE service_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    icon_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service Providers Table
CREATE TABLE service_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES service_categories(id) ON DELETE SET NULL,
    bio TEXT,
    hourly_rate DOUBLE PRECISION,
    experience_years INTEGER,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service Requests Table
CREATE TABLE service_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES service_providers(id) ON DELETE CASCADE,
    description TEXT,
    status TEXT DEFAULT 'pending',
    scheduled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery Partners Table
CREATE TABLE delivery_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type TEXT,
    vehicle_number TEXT,
    is_available BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    current_latitude DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery Assignments Table
CREATE TABLE delivery_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    delivery_partner_id UUID REFERENCES delivery_partners(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'assigned',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business Hours Table
CREATE TABLE business_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL, -- 0=Sunday, 1=Monday, ..., 6=Saturday
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(business_id, day_of_week)
);

-- Complaints Table
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, in_progress, resolved
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Jobs Table
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    poster_id UUID REFERENCES users(id) ON DELETE CASCADE, -- In case a non-business user posts (future)
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT, -- e.g., 'Retail', 'Delivery', 'Kitchen'
    job_type TEXT NOT NULL, -- 'Full-time', 'Part-time', 'Daily Wage'
    salary_range TEXT,
    location_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job Applications Table
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    applicant_id UUID REFERENCES users(id) ON DELETE CASCADE,
    experience_summary TEXT,
    status TEXT DEFAULT 'applied', -- 'applied', 'shortlisted', 'interviewed', 'hired', 'rejected'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(job_id, applicant_id)
);

-- Business Analytics Table
CREATE TABLE business_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, -- PROFILE_VIEW, CALL_CLICK, WHATSAPP_CLICK, DIRECTIONS_CLICK, SHARE_CLICK, REVIEW_SUBMITTED
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;

-- 1. Public Data (Anyone can read)
CREATE POLICY "Public read business_categories" ON business_categories FOR SELECT USING (true);
CREATE POLICY "Public read service_categories" ON service_categories FOR SELECT USING (true);
CREATE POLICY "Public read cities" ON cities FOR SELECT USING (true);
CREATE POLICY "Public read verified businesses" ON businesses FOR SELECT USING (is_verified = true);
CREATE POLICY "Public read products of verified businesses" ON products FOR SELECT USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = products.business_id AND is_verified = true)
);
CREATE POLICY "Public read product_categories of verified businesses" ON product_categories FOR SELECT USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = product_categories.business_id AND is_verified = true)
);
CREATE POLICY "Public read business_hours" ON business_hours FOR SELECT USING (true);
CREATE POLICY "Public read reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Public read user names and avatars" ON users FOR SELECT USING (true);

-- 2. Admin Data (Admins can manage everything)
-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

CREATE POLICY "Admins manage all" ON users FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON addresses FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON business_categories FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON businesses FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON product_categories FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON products FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON carts FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON cart_items FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON orders FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON order_status_history FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON order_items FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON reviews FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON notifications FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON service_categories FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON service_providers FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON service_requests FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON delivery_partners FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON delivery_assignments FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON business_hours FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON complaints FOR ALL USING (is_admin());
CREATE POLICY "Admins manage all" ON cities FOR ALL USING (is_admin());

CREATE POLICY "Admins manage all" ON business_analytics FOR ALL USING (is_admin());

-- 3. User Data (Authenticated users can manage their own data)
CREATE POLICY "Users insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id AND (role = 'customer' OR role = 'business_owner'));
CREATE POLICY "Users manage own profile" ON users FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id AND role = (SELECT role FROM users WHERE id = auth.uid()));
CREATE POLICY "Users manage own addresses" ON addresses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own carts" ON carts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own cart items" ON cart_items FOR ALL USING (
    EXISTS (SELECT 1 FROM carts WHERE id = cart_items.cart_id AND user_id = auth.uid())
);
CREATE POLICY "Users manage own orders" ON orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own order items" ON order_items FOR ALL USING (
    EXISTS (SELECT 1 FROM orders WHERE id = order_items.order_id AND user_id = auth.uid())
);
CREATE POLICY "Users read own order history" ON order_status_history FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE id = order_status_history.order_id AND user_id = auth.uid())
);
CREATE POLICY "Users manage own order status history" ON order_status_history FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE id = order_status_history.order_id AND user_id = auth.uid())
);
CREATE POLICY "Users read own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users delete own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users insert own reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (
    auth.uid() = user_id
    AND business_id = (SELECT r.business_id FROM reviews r WHERE r.id = reviews.id)
);
CREATE POLICY "Users delete own reviews" ON reviews FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users manage own complaints" ON complaints FOR ALL USING (auth.uid() = user_id);

-- Analytics policies
CREATE POLICY "Anyone can insert analytics" ON business_analytics FOR INSERT WITH CHECK (
    (auth.uid() IS NULL AND user_id IS NULL) OR (auth.uid() = user_id)
);
CREATE POLICY "Owners read own business analytics" ON business_analytics FOR SELECT USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = business_analytics.business_id AND owner_id = auth.uid())
);

-- 4. Business Owner Data (Owners manage their businesses)
-- Owners can insert their own business but it must be unverified
CREATE POLICY "Owners read own business" ON businesses FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "Owners insert own business" ON businesses FOR INSERT
WITH CHECK (auth.uid() = owner_id AND is_verified IS FALSE);

-- Owners can update their own business but cannot change is_verified (unless admin)
CREATE POLICY "Owners update own business" ON businesses FOR UPDATE
USING (auth.uid() = owner_id)
WITH CHECK (
    auth.uid() = owner_id
    AND (
        -- Verification can only be set to TRUE by an admin
        (is_verified IS FALSE)
        OR (is_verified = (SELECT b.is_verified FROM businesses b WHERE b.id = businesses.id))
        OR is_admin()
    )
);

-- Owners can delete their own business
CREATE POLICY "Owners delete own business" ON businesses FOR DELETE
USING (auth.uid() = owner_id);

CREATE POLICY "Owners manage own products" ON products FOR ALL USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = products.business_id AND owner_id = auth.uid())
);
CREATE POLICY "Owners manage own product categories" ON product_categories FOR ALL USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = product_categories.business_id AND owner_id = auth.uid())
);
CREATE POLICY "Owners manage own business hours" ON business_hours FOR ALL USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = business_hours.business_id AND owner_id = auth.uid())
);
CREATE POLICY "Owners read orders for their business" ON orders FOR SELECT USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = orders.business_id AND owner_id = auth.uid())
);

-- ==========================================
-- SEED DATA (Internal/Core)
-- ==========================================

-- Seed Cities
INSERT INTO cities (name, state, district) VALUES
('Degloor', 'Maharashtra', 'Nanded'),
('Nanded', 'Maharashtra', 'Nanded')
ON CONFLICT (name) DO NOTHING;

-- Seed Service Categories
INSERT INTO service_categories (name, icon_name) VALUES
('Electrician', 'electrical_services'),
('Plumber', 'plumbing'),
('Carpenter', 'construction'),
('Cleaner', 'cleaning_services')
ON CONFLICT (name) DO NOTHING;

-- Seed Business Categories
INSERT INTO business_categories (name, icon_name, display_order) VALUES
('Grocery', 'shopping_basket_rounded', 1),
('Food', 'restaurant_rounded', 2),
('Hardware', 'construction_rounded', 3),
('Electronics', 'bolt_rounded', 4),
('Pharmacy', 'medical_services_rounded', 5)
ON CONFLICT (name) DO NOTHING;

-- ==========================================
-- SPATIAL FUNCTIONS & TRIGGERS
-- ==========================================

-- Function to update location geography from latitude and longitude
CREATE OR REPLACE FUNCTION update_business_location()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL) THEN
        NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    ELSE
        NEW.location := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update location on insert or update
CREATE TRIGGER tr_update_business_location
BEFORE INSERT OR UPDATE OF latitude, longitude ON businesses
FOR EACH ROW EXECUTE FUNCTION update_business_location();

-- Spatial Index for performance
CREATE INDEX IF NOT EXISTS idx_businesses_location ON businesses USING GIST (location);

-- Analytics Indexes
CREATE INDEX IF NOT EXISTS idx_business_analytics_business_id ON business_analytics(business_id);
CREATE INDEX IF NOT EXISTS idx_business_analytics_event_type ON business_analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_business_analytics_created_at ON business_analytics(created_at);

-- Core Feature Indexes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_business_id ON orders(business_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_products_business_id ON products(business_id);
CREATE INDEX IF NOT EXISTS idx_business_hours_business_id ON business_hours(business_id);

-- RPC Function for radius search
CREATE OR REPLACE FUNCTION get_businesses_in_radius(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_meters FLOAT
)
RETURNS TABLE (
    id UUID,
    owner_id UUID,
    name TEXT,
    owner_name TEXT,
    description TEXT,
    category_id UUID,
    city_id UUID,
    address_text TEXT,
    whatsapp_number TEXT,
    phone_number TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location GEOGRAPHY(POINT, 4326),
    discovery_radius DOUBLE PRECISION,
    rating DOUBLE PRECISION,
    is_open BOOLEAN,
    is_verified BOOLEAN,
    image_url TEXT,
    created_at TIMESTAMPTZ,
    distance_km FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM search_businesses_in_radius(
        user_lat, user_lng, radius_meters,
        NULL, NULL, FALSE, TRUE, 0.0, 50, 0
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- RPC Function for advanced business search in radius
-- Function to check if a business is currently open
CREATE OR REPLACE FUNCTION is_business_open(b_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    day_num INTEGER;
    curr_time TIME;
    has_hours BOOLEAN;
BEGIN
    -- Get current day of week (0-6)
    day_num := EXTRACT(DOW FROM (NOW() AT TIME ZONE 'Asia/Kolkata'));
    -- Get current time
    curr_time := (NOW() AT TIME ZONE 'Asia/Kolkata')::TIME;

    -- Check if hours are defined for this business at all
    SELECT EXISTS (
        SELECT 1 FROM business_hours
        WHERE business_id = b_id
    ) INTO has_hours;

    -- If no hours defined, assume open (falls back to business.is_open manual flag)
    IF NOT has_hours THEN
        RETURN TRUE;
    END IF;

    RETURN EXISTS (
        SELECT 1 FROM business_hours
        WHERE business_id = b_id
        AND day_of_week = day_num
        AND is_closed = false
        AND curr_time >= open_time
        AND curr_time <= close_time
    );
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION search_businesses_in_radius(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_meters FLOAT,
    search_term TEXT DEFAULT NULL,
    category_id UUID DEFAULT NULL,
    open_now BOOLEAN DEFAULT FALSE,
    verified_only BOOLEAN DEFAULT FALSE,
    min_rating FLOAT DEFAULT 0.0,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    owner_id UUID,
    name TEXT,
    owner_name TEXT,
    description TEXT,
    category_id UUID,
    city_id UUID,
    address_text TEXT,
    whatsapp_number TEXT,
    phone_number TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location GEOGRAPHY(POINT, 4326),
    discovery_radius DOUBLE PRECISION,
    rating DOUBLE PRECISION,
    is_open BOOLEAN,
    is_verified BOOLEAN,
    image_url TEXT,
    created_at TIMESTAMPTZ,
    distance_km FLOAT
) AS $$
DECLARE
    u_loc GEOGRAPHY;
BEGIN
    u_loc := ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography;

    RETURN QUERY
    SELECT
        b.id, b.owner_id, b.name, b.owner_name, b.description, b.category_id, b.city_id,
        b.address_text, b.whatsapp_number, b.phone_number, b.latitude, b.longitude,
        b.location, b.discovery_radius, b.rating,
        (b.is_open AND is_business_open(b.id)) AS is_open,
        b.is_verified, b.image_url,
        b.created_at,
        ST_Distance(b.location, u_loc) / 1000.0 AS distance_km
    FROM businesses b
    WHERE ST_DWithin(b.location, u_loc, radius_meters)
    AND (NOT verified_only OR b.is_verified = true)
    AND (b.rating >= min_rating)
    AND (
        search_businesses_in_radius.search_term IS NULL
        OR search_businesses_in_radius.search_term = ''
        OR b.name ILIKE '%' || search_businesses_in_radius.search_term || '%'
        OR b.description ILIKE '%' || search_businesses_in_radius.search_term || '%'
    )
    AND (search_businesses_in_radius.category_id IS NULL OR b.category_id = search_businesses_in_radius.category_id)
    AND (NOT open_now OR (b.is_open = true AND is_business_open(b.id)))
    ORDER BY
        (CASE WHEN (b.is_open AND is_business_open(b.id)) THEN 0 ELSE 1 END),
        (CASE WHEN b.is_verified THEN 0 ELSE 1 END),
        distance_km
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- RPC Function for product search in radius
CREATE OR REPLACE FUNCTION search_products_in_radius(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_meters FLOAT,
    search_term TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    business_id UUID,
    category_id UUID,
    name TEXT,
    description TEXT,
    price DOUBLE PRECISION,
    image_url TEXT,
    is_available BOOLEAN,
    stock_quantity INTEGER,
    track_inventory BOOLEAN,
    created_at TIMESTAMPTZ,
    distance_km FLOAT,
    is_open BOOLEAN -- Business status
) AS $$
DECLARE
    u_loc GEOGRAPHY;
BEGIN
    u_loc := ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography;

    RETURN QUERY
    SELECT
        p.id, p.business_id, p.category_id, p.name, p.description, p.price, p.image_url,
        p.is_available, p.stock_quantity, p.track_inventory, p.created_at,
        ST_Distance(b.location, u_loc) / 1000.0 AS distance_km,
        (b.is_open AND is_business_open(b.id)) AS is_open
    FROM products p
    JOIN businesses b ON p.business_id = b.id
    WHERE ST_DWithin(b.location, u_loc, radius_meters)
    AND b.is_verified = true
    AND (search_products_in_radius.search_term IS NULL OR search_products_in_radius.search_term = '' OR p.name ILIKE '%' || search_products_in_radius.search_term || '%')
    ORDER BY distance_km
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to calculate delivery fee based on distance
-- Rule: ₹20 base for up to 3km, then ₹10 per additional km
CREATE OR REPLACE FUNCTION calculate_delivery_fee(
    business_id UUID,
    address_id UUID
)
RETURNS FLOAT AS $$
DECLARE
    biz_loc GEOGRAPHY;
    usr_loc GEOGRAPHY;
    dist_meters FLOAT;
    fee FLOAT;
BEGIN
    -- Get business location
    SELECT location INTO biz_loc FROM businesses WHERE id = business_id;
    -- Get user address location
    SELECT ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography INTO usr_loc FROM addresses WHERE id = address_id;

    IF biz_loc IS NULL OR usr_loc IS NULL THEN
        RETURN 0.0;
    END IF;

    -- Calculate distance in meters
    dist_meters := ST_Distance(biz_loc, usr_loc);

    -- Apply pricing rule
    IF dist_meters <= 3000 THEN
        fee := 20.0;
    ELSE
        -- ₹20 base + ₹10 per km over 3km (rounded up)
        fee := 20.0 + (CEIL((dist_meters - 3000) / 1000.0) * 10.0);
    END IF;

    RETURN fee;
END;
$$ LANGUAGE plpgsql STABLE;

-- ==========================================
-- REALTIME CONFIGURATION
-- ==========================================

-- Enable Realtime for specific tables by adding them to the supabase_realtime publication
DO $$
BEGIN
  -- Ensure the publication exists
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;

  -- Add tables to publication if they are not already present
  -- We use a sub-block to handle cases where tables might already be in the publication
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE orders, notifications, delivery_assignments, reviews, service_requests;
  EXCEPTION
    WHEN others THEN
      -- If adding all at once fails (e.g. one is already there), try one by one
      BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE orders; EXCEPTION WHEN others THEN NULL; END;
      BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE notifications; EXCEPTION WHEN others THEN NULL; END;
      BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE delivery_assignments; EXCEPTION WHEN others THEN NULL; END;
      BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE reviews; EXCEPTION WHEN others THEN NULL; END;
      BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE service_requests; EXCEPTION WHEN others THEN NULL; END;
  END;
END $$;
