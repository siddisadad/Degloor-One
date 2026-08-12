-- ==========================================
-- DEGLOOR ONE - OPEN NOW TEST DATA
-- ==========================================

BEGIN;

-- Update one original business to be open late for testing
UPDATE business_hours
SET close_time = '23:30:00'
WHERE business_id IN (SELECT id FROM businesses WHERE name = 'Hotel Degloor Deluxe');

-- Ensure the 'is_open' manual flag is true
UPDATE businesses SET is_open = true WHERE name IN ('Hotel Degloor Deluxe', 'Ganesh Sweet Mart', 'Power House Gym', 'The Corner Cafe');

COMMIT;
