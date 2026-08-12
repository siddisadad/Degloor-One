-- Migration to enhance business_analytics (business_events)
-- Part 9: Business Analytics

-- Add metadata column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='business_analytics' AND column_name='metadata') THEN
        ALTER TABLE business_analytics ADD COLUMN metadata JSONB DEFAULT '{}';
    END IF;
END $$;

-- Ensure indexes for performance
CREATE INDEX IF NOT EXISTS idx_business_analytics_business_id ON business_analytics(business_id);
CREATE INDEX IF NOT EXISTS idx_business_analytics_event_type ON business_analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_business_analytics_created_at ON business_analytics(created_at);

-- Harden RLS for analytics
DROP POLICY IF EXISTS "Anyone can insert analytics" ON business_analytics;
CREATE POLICY "Anyone can insert analytics" ON business_analytics FOR INSERT WITH CHECK (
    -- Prevent users from spoofing other users' IDs in analytics if they are logged in
    (auth.uid() IS NULL AND user_id IS NULL) OR (auth.uid() = user_id)
);

-- Ensure owners can only see their own business analytics (already in schema.sql but reinforcing)
DROP POLICY IF EXISTS "Owners read own business analytics" ON business_analytics;
CREATE POLICY "Owners read own business analytics" ON business_analytics FOR SELECT USING (
    EXISTS (SELECT 1 FROM businesses WHERE id = business_analytics.business_id AND owner_id = auth.uid())
);
