-- ==========================================
-- DEGLOOR ONE - BUSINESS SEED DATA
-- ==========================================

-- NOTE: This script assumes the schema from schema.sql is already applied.

BEGIN;

-- 1. Seed Cities (If not already present)
INSERT INTO cities (name, state, district)
VALUES ('Degloor', 'Maharashtra', 'Nanded')
ON CONFLICT (name) DO NOTHING;

-- 2. Seed Business Categories (If not already present)
INSERT INTO business_categories (name, icon_name, display_order)
VALUES
('Grocery', 'shopping_basket_rounded', 1),
('Food', 'restaurant_rounded', 2),
('Hardware', 'construction_rounded', 3),
('Electronics', 'bolt_rounded', 4),
('Pharmacy', 'medical_services_rounded', 5),
('Automotive', 'directions_car_rounded', 6),
('Clothing', 'checkroom_rounded', 7)
ON CONFLICT (name) DO UPDATE SET
    icon_name = EXCLUDED.icon_name,
    display_order = EXCLUDED.display_order;

-- 3. Create dummy users and businesses
DO $$
DECLARE
    city_id_degloor UUID;
    cat_grocery UUID;
    cat_food UUID;
    cat_hardware UUID;
    cat_pharmacy UUID;
    cat_electronics UUID;
    cat_clothing UUID;
    cat_automotive UUID;
    user_id_1 UUID := '00000000-0000-0000-0000-000000000001';
    user_id_2 UUID := '00000000-0000-0000-0000-000000000002';
    user_id_3 UUID := '00000000-0000-0000-0000-000000000003';
    user_id_4 UUID := '00000000-0000-0000-0000-000000000004';
    user_id_5 UUID := '00000000-0000-0000-0000-000000000005';
    user_id_6 UUID := '00000000-0000-0000-0000-000000000006';
BEGIN
    -- Get City ID
    SELECT id INTO city_id_degloor FROM cities WHERE name = 'Degloor' LIMIT 1;

    -- Get Category IDs
    SELECT id INTO cat_grocery FROM business_categories WHERE name = 'Grocery' LIMIT 1;
    SELECT id INTO cat_food FROM business_categories WHERE name = 'Food' LIMIT 1;
    SELECT id INTO cat_hardware FROM business_categories WHERE name = 'Hardware' LIMIT 1;
    SELECT id INTO cat_pharmacy FROM business_categories WHERE name = 'Pharmacy' LIMIT 1;
    SELECT id INTO cat_electronics FROM business_categories WHERE name = 'Electronics' LIMIT 1;
    SELECT id INTO cat_clothing FROM business_categories WHERE name = 'Clothing' LIMIT 1;
    SELECT id INTO cat_automotive FROM business_categories WHERE name = 'Automotive' LIMIT 1;

    -- 3. Create auth users
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role, aud, confirmation_token)
    VALUES
    (user_id_1, 'owner1@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_2, 'owner2@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_3, 'owner3@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_4, 'owner4@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_5, 'owner5@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_6, 'owner6@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', '')
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create public users
    INSERT INTO users (id, email, full_name, role)
    VALUES
    (user_id_1, 'owner1@degloor.com', 'Rajesh Patil', 'business_owner'),
    (user_id_2, 'owner2@degloor.com', 'Suresh Deshmukh', 'business_owner'),
    (user_id_3, 'owner3@degloor.com', 'Anjali Kulkarni', 'business_owner'),
    (user_id_4, 'owner4@degloor.com', 'Vinod Gupta', 'business_owner'),
    (user_id_5, 'owner5@degloor.com', 'Meena Sharma', 'business_owner'),
    (user_id_6, 'owner6@degloor.com', 'Rahul More', 'business_owner')
    ON CONFLICT (id) DO NOTHING;

    -- 5. Seed Businesses

    INSERT INTO businesses (name, owner_name, owner_id, description, category_id, city_id, address_text, whatsapp_number, phone_number, latitude, longitude, discovery_radius, rating, is_verified, image_url)
    VALUES
    ('Patil Kirana Store', 'Rajesh Patil', user_id_1, 'One stop shop for all your daily needs.', cat_grocery, city_id_degloor, 'Main Road, Degloor', '+919876543210', '+919876543210', 18.5525, 77.5845, 10.0, 4.5, true, 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80'),
    ('Hotel Degloor Deluxe', 'Suresh Deshmukh', user_id_2, 'Authentic Maharashtrian cuisine.', cat_food, city_id_degloor, 'Bus Stand Road, Degloor', '+919876543211', '+919876543211', 18.5510, 77.5860, 15.0, 4.2, true, 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80'),
    ('Om Hardware & Tools', 'Anjali Kulkarni', user_id_3, 'Quality hardware and tools.', cat_hardware, city_id_degloor, 'Industrial Area, Degloor', '+919876543212', '+919876543212', 18.5550, 77.5800, 12.0, 4.8, true, 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?auto=format&fit=crop&w=800&q=80'),
    ('City Medical', 'Dr. Patil', user_id_1, '24/7 Pharmacy services.', cat_pharmacy, city_id_degloor, 'Near Civil Hospital, Degloor', '+919876543213', '+919876543213', 18.5530, 77.5830, 8.0, 4.9, true, 'https://images.unsplash.com/photo-1576602976047-174e57a47881?auto=format&fit=crop&w=800&q=80'),
    ('Modern Electronics', 'Vinod Gupta', user_id_4, 'Latest gadgets and appliances.', cat_electronics, city_id_degloor, 'Market Yard Road, Degloor', '+919876543214', '+919876543214', 18.5540, 77.5820, 10.0, 4.6, true, 'https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=800&q=80'),
    ('Style Point Clothing', 'Meena Sharma', user_id_5, 'Trendy fashion for all.', cat_clothing, city_id_degloor, 'Opposite Shivaji Statue, Degloor', '+919876543215', '+919876543215', 18.5515, 77.5855, 12.0, 4.4, true, 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=80'),
    ('Degloor Auto Care', 'Rahul More', user_id_6, 'Professional vehicle repairs.', cat_automotive, city_id_degloor, 'Nanded-Bidar Highway, Degloor', '+919876543216', '+919876543216', 18.5600, 77.5750, 20.0, 4.7, true, 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=800&q=80')
    ON CONFLICT (owner_id, name) DO NOTHING;

    -- 6. Seed Products
    BEGIN
        DECLARE
            patil_id UUID;
            cat_dairy UUID;
            cat_grains UUID;
        BEGIN
            SELECT id INTO patil_id FROM businesses WHERE name = 'Patil Kirana Store' LIMIT 1;
            IF patil_id IS NOT NULL THEN
                INSERT INTO product_categories (business_id, name) VALUES (patil_id, 'Dairy') ON CONFLICT (business_id, name) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO cat_dairy;
                INSERT INTO product_categories (business_id, name) VALUES (patil_id, 'Grains') ON CONFLICT (business_id, name) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO cat_grains;
                INSERT INTO products (business_id, category_id, name, description, price, is_available, stock_quantity) VALUES
                (patil_id, cat_dairy, 'Fresh Milk (1L)', 'Pure buffalo milk.', 60.0, true, 50),
                (patil_id, cat_grains, 'Basmati Rice (1kg)', 'Premium rice.', 120.0, true, 100)
                ON CONFLICT (business_id, name) DO NOTHING;
            END IF;
        END;

        DECLARE
            hotel_id UUID;
            cat_veg UUID;
        BEGIN
            SELECT id INTO hotel_id FROM businesses WHERE name = 'Hotel Degloor Deluxe' LIMIT 1;
            IF hotel_id IS NOT NULL THEN
                INSERT INTO product_categories (business_id, name) VALUES (hotel_id, 'Vegetarian') ON CONFLICT (business_id, name) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO cat_veg;
                INSERT INTO products (business_id, category_id, name, description, price, is_available) VALUES
                (hotel_id, cat_veg, 'Special Veg Thali', 'Full meal.', 150.0, true),
                (hotel_id, cat_veg, 'Paneer Butter Masala', 'Creamy curry.', 180.0, true)
                ON CONFLICT (business_id, name) DO NOTHING;
            END IF;
        END;
    END;

    -- 7. Seed Business Hours
    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, d, '09:00:00', '21:00:00'
    FROM businesses, generate_series(0, 6) AS d
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

END $$;

COMMIT;
