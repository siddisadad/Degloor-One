ALTER TABLE orders ADD COLUMN delivery_otp_cipher TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS uq_delivery_assignments_order ON delivery_assignments(order_id);
