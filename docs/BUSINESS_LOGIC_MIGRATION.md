# DEGLOOR ONE — Business Logic Migration

Flutter stays a presentation + API client. Spring Boot owns business rules, security, pricing, inventory, OTP, and order state.

This audit maps every current Flutter/Supabase responsibility onto a Java module. Status values:

- `AUDITED` — documented, not yet served by Java
- `SKELETON` — Java module exists
- `IMPLEMENTED` — Java API enforces the rule
- `FLUTTER_CLIENT` — Dart client exists; screen still on showcase/Supabase until `JAVA_API_BASE_URL` is set
- `REMOVED` — Flutter no longer owns the rule

Supabase is **not deleted**. Showcase (`kUseShowcaseData`) and guest bypass remain for the Degloor demo. Java is the target authority for live traffic.

---

## Architecture

```text
Flutter (UI + local state + API client)
        │  HTTPS / REST  /api/v1
        ▼
Spring Boot (controllers → services → repositories)
        │
   PostgreSQL (Flyway)
```

Optional: Redis for short-lived OTP (v1 stores hashed OTP on the order row).

---

## Flutter Logic → Java

| Flutter logic | Current responsibility | Target Java module | Target API | Database | Status |
|---|---|---|---|---|---|
| Email/phone/Google sign-in, guest bypass | `SupabaseAuthManager`, `GuestAuthUser` | `auth` | `POST /auth/register`, `/login`, `/refresh`, `/logout`, `GET /auth/me` | `users`, `refresh_tokens` | IMPLEMENTED |
| Role routing | `InitialRedirectWidget` + `getCurrentUserRole` | `auth` + `user` | `GET /auth/me` (`role`) | `users.role` | IMPLEMENTED |
| Profile read/update | `UserService` | `user` | `GET/PUT /users/me` | `users` | IMPLEMENTED |
| Saved addresses + default | `AddressService` | `address` | `/users/me/addresses` | `addresses` | IMPLEMENTED |
| Radius search, categories, owned shops | `DiscoveryService` + RPCs `search_*_in_radius` | `business` | `GET /businesses`, `/businesses/{id}` | `businesses`, `business_categories`, `business_hours` | IMPLEMENTED |
| Public shop, hours, catalogue, product | `ShopService` | `business` + `product` | `GET /businesses/{id}`, `/products/{id}`, `/businesses/{id}/products` | `businesses`, `products`, `product_categories` | IMPLEMENTED |
| Owner register/edit/hours/products | `BusinessService.requireOwned*` | `business` + `product` | `POST/PUT /businesses`, `/products` | same | IMPLEMENTED |
| Engagement events | `ShopService.trackEvent` | `analytics` | `POST /analytics/events`, `GET /businesses/{id}/insights` | `business_analytics` | IMPLEMENTED |
| Cart add/qty/clear, one shop per cart | `CartService` + RPCs `add_to_cart`, `update_cart_quantity`, `clear_cart` | `cart` | `/cart`, `/cart/items` | `carts`, `cart_items` | IMPLEMENTED |
| Server-side checkout pricing | `OrderService.placeOrder` + RPC `place_order` | `order` | `POST /orders` | `orders`, `order_items`, `products`, `carts` | IMPLEMENTED |
| Order list/cancel/owner status | `OrderService` + `cancel_order` / `update_order_status` | `order` | `GET /orders`, `POST /orders/{id}/cancel`, `POST /orders/{id}/status` | `orders`, `order_status_history` | IMPLEMENTED |
| Order state machine | `OrderLifecycle` (Dart) | `order` `OrderStateMachine` | same | `orders.status` | IMPLEMENTED |
| Delivery accept/pickup/OTP | `DeliveryService` + RPCs | `delivery` | `/delivery/**` | `delivery_partners`, `delivery_assignments`, `orders` | IMPLEMENTED |
| Delivery OTP generate/verify | SQL trigger + `confirm_delivery_with_otp` | `delivery` `OtpService` | `POST /delivery/orders/{id}/otp/verify` | `orders.delivery_otp_hash` | IMPLEMENTED |
| Notifications | `NotificationService` | `notification` | `/notifications` | `notifications` | IMPLEMENTED |
| Service providers + requests | `ServiceMarketplaceService` | `marketplace` | `/services/**` | `service_*` | IMPLEMENTED |
| Jobs + apply | `JobService` + `apply_to_job` | `job` | `/jobs/**` | `jobs`, `job_applications` | IMPLEMENTED |
| Reviews (1 per user/shop) | `ShopService.addReview` | `review` | `POST /reviews`, `GET /businesses/{id}/reviews` | `reviews` | IMPLEMENTED |
| Complaints | `ShopService.reportListing` | `review` + `admin` | `POST /complaints` | `complaints` | IMPLEMENTED |
| Admin verify/resolve/categories | `AdminService` | `admin` | `/admin/**` | `users`, `businesses`, `complaints` | IMPLEMENTED |
| Delivery fee | RPC `calculate_delivery_fee` (₹20 + ₹10/km after 3km) | `order` | computed in checkout | `addresses`, `businesses` | IMPLEMENTED |
| Device GPS | `LocationService` | stays Flutter | `POST /delivery/location` only | — | FLUTTER_CLIENT |
| WhatsApp launch | `WhatsAppService` | stays Flutter | — | — | stays Flutter |
| Showcase catalog | `ShowcaseCatalog` | Java seed profile `dev` | — | Flyway seed | IMPLEMENTED |
| Login health probe | `UserService.probeReachable` | `auth` | `GET /actuator/health` | — | IMPLEMENTED |

---

## Canonical rules Java must keep

### Roles

`CUSTOMER`, `BUSINESS_OWNER`, `DELIVERY_PARTNER`, `ADMIN` (DB stores lowercase `customer` / `business_owner` / `delivery_partner` / `admin` for Flutter compatibility).

Ownership is always checked in the service, not only by `@PreAuthorize`.

### Cart

- Quantity 1–99
- Product must exist, be available, and belong to a verified shop
- Inventory check when `track_inventory`
- One business per cart; second shop returns `CART_NEEDS_REPLACEMENT`
- Flutter never supplies the payable price

### Checkout (one transaction)

Validate user → cart → load live prices → stock → subtotal → delivery fee → persist order + items → decrement stock → write history → clear cart → notify owner and customer → generate OTP.

Default COD payment stays `unpaid`. Delivery fee: ₹20 within 3 km, +₹10 per extra km (Haversine). Showcase previously used a flat ₹25; Java uses the live formula.

### Order states (existing app, not a new invented machine)

```text
pending → accepted → ready → shipping → out_for_delivery → delivered
pending|accepted|ready → cancelled
```

Owner direct transitions: `pending→accepted|cancelled`, `accepted→ready|cancelled`, `ready→cancelled`.  
Customer cancel: `pending` only.  
Owner cannot cancel after rider assignment (`shipping` / `out_for_delivery`).  
`delivered` only via OTP (partner `picked_up`, or owner counter-delivery while `ready`).

### Delivery OTP

- 4-digit, hashed at rest
- Expiry 24h
- Max 5 attempts
- One-time use
- Partner must be assigned; order must be in a confirmable state

### Reviews

One review per `(user_id, business_id)`. Rating 1–5. Eligible after a delivered order at that shop (stricter than current Flutter, which only blocked duplicates).

### Service requests

`pending → accepted|declined`; `accepted → completed`. Provider-owned.

### Jobs

Owner-scoped post. Apply once per job. Experience required.

---

## Flutter after this PR

| Area | Status |
|---|---|
| UI / navigation / Degloor theme | unchanged |
| `lib/core/api/*` | new REST client (`package:http`) |
| Existing `*_service.dart` | still showcase/Supabase unless `JAVA_API_BASE_URL` is set |
| WhatsApp / GPS UI | stays on device |

Critical Supabase RPCs are **not removed**. They remain the live fallback until the Java host is configured.

Shop open-now math lives on `ShopService.isOpenNow` / `isOpenFromHours` (Sunday=0, overnight wrap). Cart display totals use `CartService.subtotal`; checkout goes through `OrderService.placeOrderFromCart`, which strips client prices. Payable amounts still come from showcase catalog or Java/RPC.

Order and service-request buttons use `OrderService.ownerActions` / `customerActions` and `ServiceMarketplaceService.requestActions`. Widgets do not decide Degloor transitions.

---

## Remaining blockers (live cutover)

1. Point a staging Postgres at Flyway and load production data (or keep the same Supabase Postgres and let Java connect).
2. SMS/email provider for real OTP login (v1 uses email+password JWT).
3. Object storage for product images (v1 accepts URL strings).
4. Redis if OTP volume needs a dedicated store.
5. Flip Flutter `--dart-define=JAVA_API_BASE_URL=...` shop-by-shop.
6. Java JWT is separate from the current Supabase/guest session — sign in through `AuthApi` (or add a token bridge) before live cart/checkout calls succeed.
7. Then revoke client JWT / RPC execute on Supabase.

---

## Production readiness (this PR)

| Area | Score |
|---|---|
| Architecture | 8/10 |
| Security | 7/10 |
| Backend | 8/10 |
| Database | 8/10 |
| API | 8/10 |
| Flutter integration | 5/10 (REST client + optional service hooks; screens still showcase) |
| Testing | 7/10 (JUnit + H2 MockMvc; no Testcontainers in this environment) |
| Production readiness | 5/10 (needs live Postgres, secrets, Flutter cutover) |
