-- ==========================================
-- DEGLOOR ONE - SEARCH RPC FIX
-- ==========================================

-- 1. Ensure the helper function for business status is robust
CREATE OR REPLACE FUNCTION is_business_open(b_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    day_num INTEGER;
    curr_time TIME;
    has_hours BOOLEAN;
BEGIN
    -- Get current day of week (0-6)
    day_num := EXTRACT(DOW FROM (NOW() AT TIME ZONE 'Asia/Kolkata'));
    -- Get current time in IST
    curr_time := (NOW() AT TIME ZONE 'Asia/Kolkata')::TIME;

    -- Check if hours are defined for this business
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

-- 2. Drop existing function to avoid signature conflicts
DROP FUNCTION IF EXISTS search_businesses_in_radius(FLOAT, FLOAT, FLOAT, TEXT, UUID, BOOLEAN);
DROP FUNCTION IF EXISTS search_businesses_in_radius(FLOAT, FLOAT, FLOAT, TEXT, UUID, BOOLEAN, BOOLEAN, FLOAT, INTEGER, INTEGER);

-- 3. Create the definitive 10-parameter search function
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
        -- Combined open status (Manual toggle AND current business hours)
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
        (CASE WHEN (b.is_open AND is_business_open(b.id)) THEN 0 ELSE 1 END), -- Open businesses first
        (CASE WHEN b.is_verified THEN 0 ELSE 1 END), -- Verified businesses next
        distance_km -- Closest businesses last tie-breaker
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;
