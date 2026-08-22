# DEGLOOR ONE — Everything Local. One App.

DEGLOOR ONE is a hyperlocal technology platform connecting customers, businesses, service providers, and delivery partners in Degloor, Maharashtra.

## 🚀 Key Features

### 🛒 Consumer Experience
- **Discovery**: Radius-aware search and categorization for local businesses (5 / 10 / 15 km).
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
Execute the SQL scripts in the Supabase SQL Editor in this order:

1. `scratch/schema.sql` — tables, relationships, and Row Level Security (RLS) policies.
2. `scratch/secure_transactions.sql` — atomic `place_order` RPC with stock checks.
3. `scratch/secure_delivery.sql` — exclusive order accept and server-side delivery OTP.
4. `scratch/rls_order_policies.sql` — customers cannot change order status; owners can update fulfillment.
5. `scratch/secure_platform.sql` — server-side pricing, order state machine, storage policies, delivery location, indexes.
6. `scratch/jobs_services.sql` — jobs/services RLS, marketplace RPCs, and list indexes.
7. `scratch/notifications_admin.sql` — admin-only `admin_notify_user()` wrapper.

### 2. Environment Configuration
Dart-defines are owned by `lib/core/app_environment.dart`. The FlutterFlow default host (`uhaibenopzyzzuqjawlb.supabase.co`) currently does not resolve (`net::ERR_NAME_NOT_RESOLVED`). That dead host automatically enables guest login and the local showcase catalog.

Point the app at a live project for real Auth and checkout:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY --dart-define=BYPASS_AUTH=false --dart-define=SHOWCASE_DATA=false
```

Demo / Cloud Agent builds can keep the defaults and run:

```bash
flutter run --dart-define=SHOWCASE_DATA=true --dart-define=BYPASS_AUTH=true
```

After the project is live, add these **Forgot password** Redirect URLs (Authentication → URL Configuration):

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
