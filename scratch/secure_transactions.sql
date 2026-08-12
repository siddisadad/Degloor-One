-- DEGLOOR ONE - Secure Transactions (RPCs)

-- Function to place an order securely with inventory check
-- This should be called via Supabase RPC
CREATE OR REPLACE FUNCTION place_order(
    p_business_id UUID,
    p_total_amount FLOAT,
    p_delivery_address_id UUID,
    p_payment_method TEXT,
    p_items JSONB -- Array of {product_id: UUID, quantity: INT, price: FLOAT}
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id UUID;
    v_quantity INT;
    v_stock INT;
    v_track BOOLEAN;
BEGIN
    -- 1. Create the order
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

    -- 2. Process items and check inventory
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_quantity := (v_item->>'quantity')::INT;

        -- Check inventory
        SELECT stock_quantity, track_inventory INTO v_stock, v_track
        FROM products
        WHERE id = v_product_id AND business_id = p_business_id;

        IF v_track THEN
            IF v_stock < v_quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_product_id;
            END IF;

            -- Decrement stock
            UPDATE products
            SET stock_quantity = stock_quantity - v_quantity
            WHERE id = v_product_id;
        END IF;

        -- Insert order item
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
