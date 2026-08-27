-- ==========================================
-- VERIFICATION SCRIPT FOR DEGLOOR ONE CHANGES
-- ==========================================

-- 1. Test 10 KM radius search
-- This should return businesses within 10km of Degloor center (approx 18.55, 77.58)
SELECT name, distance_km, is_verified, is_open
FROM search_businesses_in_radius(18.55, 77.58, 10000);

-- 2. Test search filters
-- Search for 'Grocery' within 10km
SELECT name, rating, is_open
FROM search_businesses_in_radius(18.55, 77.58, 10000, 'Grocery');

-- 3. Test unique review constraint
-- Should fail on second insert
DO $$
DECLARE
    u_id UUID := '00000000-0000-0000-0000-000000000000';
    b_id UUID := '00000000-0000-0000-0000-000000000001';
BEGIN
    -- Ensure test rows exist in users and businesses if needed, or use real ones
    -- For this test, we assume they exist or use ON CONFLICT

    INSERT INTO reviews (user_id, business_id, rating, comment)
    VALUES (u_id, b_id, 5, 'First review')
    ON CONFLICT (user_id, business_id) DO NOTHING;

    BEGIN
        INSERT INTO reviews (user_id, business_id, rating, comment)
        VALUES (u_id, b_id, 4, 'Second review');
        RAISE EXCEPTION 'Unique constraint failed to block duplicate review!';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Success: Duplicate review blocked by unique constraint.';
    END;
END $$;

-- 4. Test product search with is_open status
SELECT name, price, distance_km, is_open
FROM search_products_in_radius(18.55, 77.58, 10000, 'Milk');

-- 5. Verify RLS (Conceptual)
-- To test RLS, one would normally use 'SET ROLE' and then try queries.
-- Example:
-- SET ROLE authenticated;
-- SET auth.uid = '...';
-- UPDATE businesses SET is_verified = true WHERE id = '...'; -- Should fail if not admin
-- SET ROLE postgres; -- Back to admin for other tests
