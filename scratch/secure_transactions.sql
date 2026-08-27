-- DEGLOOR ONE - Secure Transactions (RPCs)
-- place_order is replaced by scratch/secure_platform.sql with server-side
-- pricing, delivery fee, history, and notifications. Keep this file so
-- older checklists still have a stock-safe checkout RPC.

-- Function to place an order securely with inventory check
-- This should be called via Supabase RPC
CREATE OR REPLACE FUNCTION place_order(
    p_business_id UUID,
    p_total_amount FLOAT,
    p_delivery_address_id UUID,
    p_payment_method TEXT,
    p_items JSONB -- Array of {product_id: UUID, quantity: INT, price: FLOAT}
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id UUID;
    v_quantity INT;
    v_track BOOLEAN;
    v_updated INT;
BEGIN
    -- 1. Create the order (OTP is filled by ensure_delivery_otp trigger)
    INSERT INTO orders (
        user_id,
        business_id,
        total_amount,
        delivery_address_id,
        payment_method,
        status,
        payment_status
    ) VALUES (
        auth.uid(),
        p_business_id,
        p_total_amount,
        p_delivery_address_id,
        p_payment_method,
        'pending',
        'unpaid'
    ) RETURNING id INTO v_order_id;

    -- 2. Process items and check inventory atomically
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INT;

        SELECT track_inventory INTO v_track
        FROM products
        WHERE id = v_product_id AND business_id = p_business_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product % is not sold by this business', v_product_id;
        END IF;

        IF COALESCE(v_track, FALSE) THEN
            UPDATE products
            SET stock_quantity = stock_quantity - v_quantity
            WHERE id = v_product_id
              AND business_id = p_business_id
              AND stock_quantity >= v_quantity;
            GET DIAGNOSTICS v_updated = ROW_COUNT;
            IF v_updated = 0 THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_product_id;
            END IF;
        END IF;

        INSERT INTO order_items (
            order_id,
            product_id,
            quantity,
            price_at_purchase
        ) VALUES (
            v_order_id,
            v_product_id,
            v_quantity,
            (v_item->>'price')::FLOAT
        );
    END LOOP;

    -- 3. Clear cart for this user and business
    DELETE FROM cart_items
    WHERE cart_id IN (
        SELECT id FROM carts
        WHERE user_id = auth.uid() AND business_id = p_business_id
    );

    RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION place_order(UUID, FLOAT, UUID, TEXT, JSONB) TO authenticated;
