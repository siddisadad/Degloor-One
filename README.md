# DEGLOOR ONE — Everything Local. One App.

DEGLOOR ONE is a hyperlocal technology platform connecting customers, businesses, service providers, and delivery partners in Degloor, Maharashtra.

## 🚀 Key Features

### 🛒 Consumer Experience
- **Discovery**: Dynamic search and categorization for local businesses.
- **Catalogue**: Browse digital storefronts with real-time product listings.
- **Cart & Checkout**: Integrated commerce with support for **UPI** and **Cash on Delivery**.
- **Service Marketplace**: Find and request local service providers (Electricians, Plumbers, etc.).
- **Reviews**: Verified rating system based on completed orders.

### 🏢 Business Portal
- **Management Dashboard**: Insights into profile views and customer engagement.
- **Catalogue Control**: Add, edit, or remove products instantly.
- **Order Fulfillment**: Real-time order tracking from acceptance to delivery.

### 🚚 Logistics & Admin
- **Delivery Partner Dashboard**: Manage availability and fulfill local deliveries.
- **Admin Control Panel**: Verification queue for businesses and platform-wide category management.
- **Notifications**: Real-time in-app alerts for all transactional events.

## 🛠 Tech Stack
- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Architecture**: Modular Monolith following clean code principles.

## 🏁 Getting Started

### 1. Database Setup
Execute the SQL script located at `scratch/schema.sql` in your Supabase SQL Editor. This will create all necessary tables, relationships, and Row Level Security (RLS) policies.

### 2. Environment Configuration
Ensure your `lib/backend/supabase/supabase.dart` is updated with your specific Supabase URL and Anon Key.

### 3. Run the App
```bash
flutter pub get
flutter run
```

## 📜 Documentation
Full product, business, and technical specifications can be found in the `DEGLOOR_ONE_Documentation_v1.0` package.

---
Built by **Deshmukh Technologies**.
