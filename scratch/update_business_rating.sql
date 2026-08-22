-- ==========================================
-- DEGLOOR ONE - AUTOMATIC RATING UPDATES
-- ==========================================

-- Function to recalculate average rating for a business
CREATE OR REPLACE FUNCTION calculate_business_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_avg_rating FLOAT;
BEGIN
    -- Calculate average rating for the affected business
    SELECT AVG(rating)::FLOAT INTO v_avg_rating
    FROM reviews
    WHERE business_id = COALESCE(NEW.business_id, OLD.business_id);

    -- Update the businesses table
    UPDATE businesses
    SET rating = COALESCE(v_avg_rating, 0.0)
    WHERE id = COALESCE(NEW.business_id, OLD.business_id);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for Insert, Update, and Delete on reviews
DROP TRIGGER IF EXISTS tr_update_business_rating ON reviews;
CREATE TRIGGER tr_update_business_rating
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW EXECUTE FUNCTION calculate_business_rating();

-- Run initial update for all businesses
UPDATE businesses b
SET rating = COALESCE((SELECT AVG(rating)::FLOAT FROM reviews r WHERE r.business_id = b.id), 0.0);
