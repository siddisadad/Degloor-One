-- Demo password for every seeded account: password
-- BCrypt hash from Spring Security's documented sample.
INSERT INTO cities (id, name, state, district) VALUES
    ('30000000-0000-4000-8000-000000000001', 'Degloor', 'Maharashtra', 'Nanded');

INSERT INTO users (id, email, password_hash, full_name, role, phone_number) VALUES
    ('00000000-0000-4000-8000-000000000001', 'guest@local', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Guest Customer', 'customer', '+919890000001'),
    ('00000000-0000-4000-8000-000000000002', 'suresh@degloor.local', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Suresh Deshmukh', 'business_owner', '+919876543210'),
    ('00000000-0000-4000-8000-000000000007', 'rider@degloor.local', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Amit Jadhav', 'delivery_partner', '+919890000007'),
    ('00000000-0000-4000-8000-000000000009', 'admin@degloor.local', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'Sadad Siddi', 'admin', '+919876543210');

INSERT INTO business_categories (id, name, icon_name, display_order) VALUES
    ('40000000-0000-4000-8000-000000000001', 'Grocery', 'shopping_basket_rounded', 1),
    ('40000000-0000-4000-8000-000000000002', 'Food', 'restaurant_rounded', 2);

INSERT INTO businesses (id, owner_id, name, owner_name, description, category_id, city_id, address_text, latitude, longitude, is_verified, is_open)
VALUES
    ('10000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'Patil Kirana', 'Guest Customer', 'Daily groceries from Degloor market.', '40000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'Main Market, Degloor', 18.5522, 77.5844, TRUE, TRUE),
    ('10000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000002', 'Hotel Annapurna', 'Suresh Deshmukh', 'Veg thali and snacks.', '40000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000001', 'Bus Stand Road, Degloor', 18.5530, 77.5850, TRUE, TRUE);

INSERT INTO product_categories (id, business_id, name) VALUES
    ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Dairy'),
    ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'Grains');

INSERT INTO products (id, business_id, category_id, name, description, price, is_available, stock_quantity, track_inventory) VALUES
    ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 'Fresh Milk (1L)', 'Pure buffalo milk from nearby dairies.', 60, TRUE, 40, TRUE),
    ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000002', 'Basmati Rice (1kg)', 'Premium long-grain rice.', 120, TRUE, 40, TRUE);

INSERT INTO addresses (id, user_id, title, address_text, latitude, longitude, is_default) VALUES
    ('60000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'Home', 'Lane 2, Degloor', 18.5522, 77.5844, TRUE);

INSERT INTO delivery_partners (id, user_id, vehicle_type, vehicle_number, is_available, is_verified) VALUES
    ('70000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000007', 'bike', 'MH26 AB 1234', TRUE, TRUE);

INSERT INTO service_categories (id, name, icon_name) VALUES
    ('80000000-0000-4000-8000-000000000001', 'Electrician', 'electrical_services');
