# DEGLOOR ONE — Everything Local. One App.

DEGLOOR ONE is a hyperlocal technology platform connecting customers, businesses, service providers, and delivery partners in Degloor, Maharashtra.

## 🚀 Key Features

### 🛒 Consumer Experience
- **Discovery**: Radius-aware search and categorization for local businesses (2km - 25km).
- **Catalogue**: Browse digital storefronts with real-time product listings.
- **Cart & Checkout**: Dynamic distance-based delivery fees with support for **UPI** and **Cash on Delivery**.
- **Address Management**: Precise map-based pinning with automatic reverse geocoding.
- **Service Marketplace**: Find and request local service providers with professional profiles.

### 🏢 Business Portal
- **Real-time Dashboard**: Live insights into revenue, order volume, and customer engagement.
- **Order Fulfillment**: Real-time order tracking using Supabase data streams.
- **WhatsApp Integration**: One-tap communication with customers.

### 🚚 Logistics & Admin
- **Delivery Partner Dashboard**: Manage availability and coordinate deliveries via WhatsApp.
- **Admin Control Panel**: Verification queue for businesses and user complaint management.
- **Multi-language**: Full support for **English**, **Marathi**, and **Hindi**.

## 🛠 Tech Stack
- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Architecture**: Modular Monolith following clean code principles.

## 🏁 Getting Started

### 1. Database Setup
Execute the SQL script located at `scratch/schema.sql` in your Supabase SQL Editor. This will create all necessary tables, relationships, and Row Level Security (RLS) policies.

### 2. Environment Configuration
Ensure your `lib/backend/supabase/supabase.dart` is updated with your specific Supabase URL and Anon Key.

For **Forgot password**, add these Redirect URLs in the Supabase dashboard (Authentication → URL Configuration):

- `degloorone://degloorone.com/resetPassword` (Android / iOS)
- `http://localhost:*/resetPassword` (local web)
- your production web origin + `/resetPassword`

### 3. Run the App
```bash
flutter pub get
flutter run
```

## 📜 Documentation
Full product, business, and technical specifications can be found in the `DEGLOOR_ONE_Documentation_v1.0` package.

---
Built by **Deshmukh Technologies**.
