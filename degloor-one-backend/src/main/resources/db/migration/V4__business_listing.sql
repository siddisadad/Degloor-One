-- Listing fields for Degloor shops. Hours stay on business_hours.
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS sub_category TEXT;
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS photos TEXT NOT NULL DEFAULT '[]';
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'owner';
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
