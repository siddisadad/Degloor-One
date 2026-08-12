# Production Readiness & Security Hardening Plan

This plan addresses several critical areas including security (RLS & Roles), authentication, bug fixes, and code cleanup to prepare the DEGLOOR ONE application for production.

## User Review Required

> [!IMPORTANT]
> **Backend-Controlled Roles**: I will be removing the ability for the client to specify a user role during signup/login. Roles will default to 'customer' in the database. Business Owners will have their role updated via a secure process.
>
> **RLS Audit**: Significant changes will be made to Supabase RLS policies. This might affect existing test accounts if they were relying on permissive policies.

## Proposed Changes

---

### 1. Backend-Controlled Roles & Google Auth
**Goal**: Prevent client-side role spoofing and simplify authentication.

#### [MODIFY] [supabase_auth_manager.dart](file:///A:/Workspace/Degloor-One/lib/auth/supabase_auth/supabase_auth_manager.dart)
- Remove `signInWithEmailWithRole`, `createAccountWithEmailWithRole`, and `signInWithGoogleWithRole`.
- Update `_signInOrCreateAccount` to remove the `role` parameter.
- Ensure `role` always defaults to 'customer' in the `users` table via DB default or a single point of truth in `_signInOrCreateAccount`.

#### [MODIFY] [authentication_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/auth/authentication_widget.dart)
- Update calls to `authManager` to use standard `signIn`/`createAccount` methods without the `role` parameter.

---

### 2. Complete RLS Audit & Secure Transactions
**Goal**: Harden the database against unauthorized access and ensure transaction integrity.

#### [MODIFY] [schema.sql](file:///A:/Workspace/Degloor-One/scratch/schema.sql)
- Tighten `Users insert own profile` policy: `WITH CHECK (auth.uid() = id AND role = 'customer')`. Business owner role should only be granted via a specific action (e.g., successful business registration).
- Add RLS for `products` to prevent unauthorized updates.
- **Secure Transactions**: Implement a PostgreSQL function (RPC) for `place_order` that:
    1. Checks inventory levels.
    2. Decrements inventory.
    3. Creates the order and order items in a single transaction.

#### [NEW] [secure_transactions.sql](file:///A:/Workspace/Degloor-One/scratch/secure_transactions.sql)
- SQL script for the `place_order` RPC and other sensitive operations.

---

### 3. Redirect-Location Bug
**Goal**: Fix the initial redirection logic to be more robust.

#### [MODIFY] [initial_redirect_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/auth/initial_redirect_widget.dart)
- Add a timeout to `LocationService.updateCurrentLocation`.
- Ensure redirection happens even if location fails (using a default location or previous state).
- Handle edge cases where `getCurrentUserRole()` might return null or fail.

---

### 4. Remove Fake Data & Admin Analytics
**Goal**: Clean up the UI and ensure analytics are real.

#### [MODIFY] [admin_control_panel_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/admin/admin_control_panel_widget.dart)
- Audit and remove any hardcoded mock data.
- Ensure "Total Users", "Active Businesses", etc., are fetched from the database.

#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Remove any remaining hardcoded stat cards.

---

### 5. Consolidate Analytics & Clean Error Handling
**Goal**: Unified logging and analytics.

#### [MODIFY] [analytics.dart](file:///A:/Workspace/Degloor-One/lib/backend/supabase/analytics.dart)
- Merge `analytics_util.dart` logic here.
- Implement a unified `logEvent` method.

#### [MODIFY] [error_handler.dart](file:///A:/Workspace/Degloor-One/lib/core/error_handler.dart) [NEW]
- Create a centralized error handling utility that uses a logger instead of `print()`.
- Update existing `catch` blocks to use this utility.

---

### 6. Remove Duplicate "Open Now" Filtering
**Goal**: Performance optimization.

#### [MODIFY] [search_results_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/search/search_results_widget.dart)
- Ensure "Open Now" toggle only triggers the RPC parameter and remove any client-side filtering that duplicates this logic.

## Verification Plan

### Automated Tests
- N/A for this Flutter project (no existing test suite found except a basic widget test).

### Manual Verification
1. **Security**: Try to sign up with 'admin' role from the client (should fail or result in 'customer' role).
2. **Auth**: Verify Google login still works and assigns 'customer' role to new users.
3. **Redirect**: Test app startup with and without location permissions.
4. **Analytics**: Verify events are logged in the `business_analytics` table.
5. **Orders**: Verify inventory decrements correctly when an order is placed.
6. **Filtering**: Verify "Open Now" filter works as expected.
