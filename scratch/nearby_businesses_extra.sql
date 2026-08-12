-- ==========================================
-- DEGLOOR ONE - EXTRA NEARBY BUSINESS DATA
-- ==========================================

BEGIN;

-- Ensure categories exist
INSERT INTO business_categories (name, icon_name, display_order)
VALUES
('Sweets', 'bakery_dining_rounded', 8),
('Stationery', 'edit_note_rounded', 9),
('Mobile Services', 'phonelink_setup_rounded', 10),
('Fitness', 'fitness_center_rounded', 11),
('Cafe', 'coffee_rounded', 12)
ON CONFLICT (name) DO NOTHING;

DO $$
DECLARE
    city_id_degloor UUID;
    cat_sweets UUID;
    cat_stationery UUID;
    cat_mobile UUID;
    cat_fitness UUID;
    cat_cafe UUID;
    user_id_extra_1 UUID := '00000000-0000-0000-0000-000000000011';
    user_id_extra_2 UUID := '00000000-0000-0000-0000-000000000012';
    user_id_extra_3 UUID := '00000000-0000-0000-0000-000000000013';
BEGIN
    -- Get City ID
    SELECT id INTO city_id_degloor FROM cities WHERE name = 'Degloor' LIMIT 1;

    -- Get Category IDs
    SELECT id INTO cat_sweets FROM business_categories WHERE name = 'Sweets' LIMIT 1;
    SELECT id INTO cat_stationery FROM business_categories WHERE name = 'Stationery' LIMIT 1;
    SELECT id INTO cat_mobile FROM business_categories WHERE name = 'Mobile Services' LIMIT 1;
    SELECT id INTO cat_fitness FROM business_categories WHERE name = 'Fitness' LIMIT 1;
    SELECT id INTO cat_cafe FROM business_categories WHERE name = 'Cafe' LIMIT 1;

    -- Create extra auth users
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role, aud, confirmation_token)
    VALUES
    (user_id_extra_1, 'sweets@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_extra_2, 'fitness@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', ''),
    (user_id_extra_3, 'cafe@degloor.com', crypt('password123', gen_salt('bf')), NOW(), 'authenticated', 'authenticated', '')
    ON CONFLICT (id) DO NOTHING;

    -- Create extra public users
    INSERT INTO users (id, email, full_name, role)
    VALUES
    (user_id_extra_1, 'sweets@degloor.com', 'Ganesh Mithaiwala', 'business_owner'),
    (user_id_extra_2, 'fitness@degloor.com', 'Vikram Singh', 'business_owner'),
    (user_id_extra_3, 'cafe@degloor.com', 'Sneha Deshpande', 'business_owner')
    ON CONFLICT (id) DO NOTHING;

    -- Insert Extra Businesses
    INSERT INTO businesses (name, owner_name, owner_id, description, category_id, city_id, address_text, whatsapp_number, phone_number, latitude, longitude, discovery_radius, rating, is_verified, image_url)
    VALUES
    ('Ganesh Sweet Mart', 'Ganesh Mithaiwala', user_id_extra_1, 'Famous for Degloor Pedha and fresh sweets.', cat_sweets, city_id_degloor, 'Subhash Chowk, Degloor', '+919876543221', '+919876543221', 18.5528, 77.5848, 5.0, 4.9, true, 'https://images.unsplash.com/photo-1589119908995-c6837fa14848?auto=format&fit=crop&w=800&q=80'),
    ('Universal Stationery', 'Ganesh Mithaiwala', user_id_extra_1, 'All types of school and office stationery.', cat_stationery, city_id_degloor, 'Near Nutan Vidyalaya, Degloor', '+919876543222', '+919876543222', 18.5518, 77.5840, 3.0, 4.6, true, 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?auto=format&fit=crop&w=800&q=80'),
    ('Apex Mobile Care', 'Sneha Deshpande', user_id_extra_3, 'Quick mobile repairs and accessories.', cat_mobile, city_id_degloor, 'Cloth Market, Degloor', '+919876543223', '+919876543223', 18.5535, 77.5855, 5.0, 4.7, true, 'https://images.unsplash.com/photo-1512428559083-a40ea930a3f5?auto=format&fit=crop&w=800&q=80'),
    ('Power House Gym', 'Vikram Singh', user_id_extra_2, 'Premium fitness center with modern equipment.', cat_fitness, city_id_degloor, 'Stadium Road, Degloor', '+919876543224', '+919876543224', 18.5480, 77.5800, 10.0, 4.8, true, 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80'),
    ('The Corner Cafe', 'Sneha Deshpande', user_id_extra_3, 'Best coffee and snacks in town.', cat_cafe, city_id_degloor, 'Old Town Road, Degloor', '+919876543225', '+919876543225', 18.5560, 77.5880, 5.0, 4.5, true, 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80')
    ON CONFLICT (owner_id, name) DO NOTHING;

    -- 8. Seed Business Hours for Extra Businesses
    -- Some are open late (Open Now test at 22:30), some are closed.
    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, gs.day, '08:00:00', '23:00:00' FROM businesses CROSS JOIN generate_series(0, 6) AS gs(day) WHERE name = 'Ganesh Sweet Mart'
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, gs.day, '10:00:00', '18:00:00' FROM businesses CROSS JOIN generate_series(0, 6) AS gs(day) WHERE name = 'Universal Stationery'
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, gs.day, '10:00:00', '22:00:00' FROM businesses CROSS JOIN generate_series(0, 6) AS gs(day) WHERE name = 'Apex Mobile Care'
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, gs.day, '05:00:00', '23:30:00' FROM businesses CROSS JOIN generate_series(0, 6) AS gs(day) WHERE name = 'Power House Gym'
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

    INSERT INTO business_hours (business_id, day_of_week, open_time, close_time)
    SELECT id, gs.day, '11:00:00', '23:59:59' FROM businesses CROSS JOIN generate_series(0, 6) AS gs(day) WHERE name = 'The Corner Cafe'
    ON CONFLICT (business_id, day_of_week) DO NOTHING;

END $$;

COMMIT;
