-- ==========================================
-- DEGLOOR ONE - ADDITIONAL NEARBY BUSINESSES
-- ==========================================

BEGIN;

DO $$
DECLARE
    city_id_degloor UUID;
    cat_grocery UUID;
    cat_food UUID;
    cat_hardware UUID;
    cat_pharmacy UUID;
    cat_electronics UUID;

    -- New owner IDs
    user_id_7 UUID := '00000000-0000-0000-0000-000000000007';
    user_id_8 UUID := '00000000-0000-0000-0000-000000000008';
    user_id_9 UUID := '00000000-0000-0000-0000-000000000009';
BEGIN
    -- Get City ID
    SELECT id INTO city_id_degloor FROM cities WHERE name = 'Degloor' LIMIT 1;

    -- Get Category IDs
    SELECT id INTO cat_grocery FROM business_categories WHERE name = 'Grocery' LIMIT 1;
    SELECT id INTO cat_food FROM business_categories WHERE name = 'Food' LIMIT 1;
    SELECT id INTO cat_hardware FROM business_categories WHERE name = 'Hardware' LIMIT 1;
    SELECT id INTO cat_pharmacy FROM business_categories WHERE name = 'Pharmacy' LIMIT 1;
    SELECT id INTO cat_electronics FROM business_categories WHERE name = 'Electronics' LIMIT 1;

    -- 1. Create additional auth users
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role, aud, confirmation_token)
    VALUES
    (user_id_7, 'owner7@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_8, 'owner8@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_9, 'owner9@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', '')
    ON CONFLICT (id) DO NOTHING;

    -- 2. Create additional public users
    INSERT INTO users (id, email, full_name, role)
    VALUES
    (user_id_7, 'owner7@degloor.com', 'Amol Deshpande', 'business_owner'),
    (user_id_8, 'owner8@degloor.com', 'Kiran Shah', 'business_owner'),
    (user_id_9, 'owner9@degloor.com', 'Sunita Jadhav', 'business_owner')
    ON CONFLICT (id) DO NOTHING;

    -- 3. Seed Additional Businesses with Diverse Locations
    INSERT INTO businesses (name, owner_name, owner_id, description, category_id, city_id, address_text, whatsapp_number, phone_number, latitude, longitude, discovery_radius, rating, is_verified, image_url)
    VALUES
    ('Sai Super Market', 'Amol Deshpande', user_id_7, 'Premium grocery and daily essentials.', cat_grocery, city_id_degloor, 'Shivaji Nagar, Degloor', '+919876543217', '+919876543217', 18.5530, 77.5850, 5.0, 4.6, true, 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=800&q=80'),
    ('Prakash Electronics', 'Kiran Shah', user_id_8, 'All types of mobile repairs and accessories.', cat_electronics, city_id_degloor, 'Gandhi Chowk, Degloor', '+919876543218', '+919876543218', 18.5510, 77.5820, 3.0, 4.3, true, 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80'),
    ('Degloor Food Court', 'Sunita Jadhav', user_id_9, 'Multi-cuisine restaurant with home delivery.', cat_food, city_id_degloor, 'Near Bus Stand, Degloor', '+919876543219', '+919876543219', 18.5550, 77.5870, 8.0, 4.1, true, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80'),
    ('Janata Medicals', 'Amol Deshpande', user_id_7, 'Trusted pharmacy since 1990.', cat_pharmacy, city_id_degloor, 'Main Market, Degloor', '+919876543220', '+919876543220', 18.5500, 77.5830, 4.0, 4.7, true, 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?auto=format&fit=crop&w=800&q=80'),
    ('Vishwa Hardware', 'Kiran Shah', user_id_8, 'Sanitary ware and plumbing solutions.', cat_hardware, city_id_degloor, 'Old Town, Degloor', '+919876543221', '+919876543221', 18.5580, 77.5800, 10.0, 4.4, true, 'https://images.unsplash.com/photo-1530124560676-44b2911f430e?auto=format&fit=crop&w=800&q=80')
    ON CONFLICT (owner_id, name) DO NOTHING;

    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, d, '08:30:00', '21:30:00'
    FROM businesses CROSS JOIN generate_series(0, 6) AS d
    WHERE owner_id IN (user_id_7, user_id_8, user_id_9)
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

END $$;

COMMIT;
