-- ==========================================
-- DEGLOOR ONE - OPEN NOW FILTER MIGRATION
-- ==========================================

-- 1. Helper function for business status
CREATE OR REPLACE FUNCTION is_business_open(b_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    day_num INTEGER;
    curr_time TIME;
BEGIN
    -- Get current day of week (0-6)
    day_num := EXTRACT(DOW FROM (NOW() AT TIME ZONE 'Asia/Kolkata'));
    -- Get current time in IST
    curr_time := (NOW() AT TIME ZONE 'Asia/Kolkata')::TIME;

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

-- 2. Update search function
CREATE OR REPLACE FUNCTION search_businesses_in_radius(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_meters FLOAT,
    search_term TEXT DEFAULT NULL,
    category_id UUID DEFAULT NULL,
    open_now BOOLEAN DEFAULT FALSE
)
RETURNS SETOF businesses AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM businesses
    WHERE ST_DWithin(
        location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        radius_meters
    )
    AND is_verified = true
    AND (search_businesses_in_radius.search_term IS NULL OR name ILIKE '%' || search_businesses_in_radius.search_term || '%')
    AND (search_businesses_in_radius.category_id IS NULL OR businesses.category_id = search_businesses_in_radius.category_id)
    AND (NOT open_now OR (is_open = true AND is_business_open(id)))
    ORDER BY ST_Distance(
        location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
    );
END;
$$ LANGUAGE plpgsql STABLE;
