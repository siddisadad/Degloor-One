# Role-Based Redirection Implementation Plan

This plan aims to centralize the redirection logic after login and during app startup, ensuring users are sent to the correct dashboard (Customer, Business, or Admin) based on their role stored in the database.

## User Review Required

> [!IMPORTANT]
> The redirection logic will be integrated into the main navigation flow. This means that whenever a user's authentication state changes (e.g., login, logout), the app will automatically determine the correct screen to display.

## Proposed Changes

### 1. Auth & User Providers
Update the base and Supabase-specific user providers to include the `role` property, fetching it during the authentication process.

#### [MODIFY] [base_auth_user_provider.dart](file:///A:/Workspace/Degloor-One/lib/auth/base_auth_user_provider.dart)
- Add `role` getter to `BaseAuthUser`.

#### [MODIFY] [supabase_user_provider.dart](file:///A:/Workspace/Degloor-One/lib/auth/supabase_auth/supabase_user_provider.dart)
- Update `DegloorOneSupabaseUser` to accept and store a `role` string.
- Update `degloorOneSupabaseUserStream` to fetch the user's role from the `users` table asynchronously using `asyncMap`.

### 2. Navigation Logic
Centralize the redirection logic in the router configuration.

#### [MODIFY] [nav.dart](file:///A:/Workspace/Degloor-One/lib/flutter_flow/nav/nav.dart)
- Update the `/` (initialize) route to use a more sophisticated builder or redirect that checks the user's role.
- We will implement an `InitialRedirectWidget` to handle the transition smoothly, or modify the builder to check `appStateNotifier.user?.role`.

#### [NEW] [initial_redirect_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/auth/initial_redirect_widget.dart)
- Create a simple widget that handles the initial routing logic. It will show a loading state while the user/role is being determined and then use `context.goNamed` to navigate to the appropriate home screen.

### 3. Authentication UI
Simplify the redirection logic in the login and signup screens to rely on the centralized navigation or ensure they align with the new role-based structure.

#### [MODIFY] [authentication_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/auth/authentication_widget.dart)
- Clean up the manual redirection logic in the "Sign In" and "Create Account" handlers if necessary, ensuring they trigger the centralized flow or use the correct role-based destinations.

## Verification Plan

### Automated Tests
- N/A (Manual verification is more appropriate for navigation flows in this context).

### Manual Verification
1. **Login as Customer**: Verify redirection to `CustomerHome`.
2. **Login as Business Owner**: Verify redirection to `BusinessDashboard`.
3. **Login as Admin**: Verify redirection to `AdminControlPanel`.
4. **App Restart (Logged In)**: Close and reopen the app while logged in as a specific role and verify it lands on the correct dashboard.
5. **App Restart (Logged Out)**: Verify it lands on the `Authentication` screen.
