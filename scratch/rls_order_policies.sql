-- DEGLOOR ONE — tighten order RLS
-- Customers may read/insert their own orders but must not change status.
-- Business owners may update fulfillment status for their shop.

DROP POLICY IF EXISTS "Users manage own orders" ON orders;

CREATE POLICY "Users read own orders" ON orders
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own orders" ON orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owners update orders for their business" ON orders;

CREATE POLICY "Owners update orders for their business" ON orders
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM businesses
      WHERE id = orders.business_id AND owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM businesses
      WHERE id = orders.business_id AND owner_id = auth.uid()
    )
    AND status IN (
      'pending',
      'accepted',
      'ready',
      'shipping',
      'out_for_delivery',
      'delivered',
      'cancelled'
    )
  );
