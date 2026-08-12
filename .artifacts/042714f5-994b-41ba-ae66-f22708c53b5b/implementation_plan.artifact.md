# Fix Authentication Issues

The goal is to resolve issues in the authentication flow, specifically regarding Role-Based Access Control (RBAC) in Supabase RLS and improving error handling/navigation in the Flutter app.

## User Review Required

> [!IMPORTANT]
> The Supabase RLS policy for the `users` table currently restricts account creation only to the 'customer' role. I will be updating this to allow 'business_owner' as well.

## Proposed Changes

### Supabase Schema

#### [MODIFY] [schema.sql](file:///A:/Workspace/Degloor-One/scratch/schema.sql)
- Update the `Users insert own profile` RLS policy to allow both 'customer' and 'business_owner' roles.

### Flutter Authentication Logic

#### [MODIFY] [supabase_auth_manager.dart](file:///A:/Workspace/Degloor-One/lib/auth/supabase_auth/supabase_auth_manager.dart)
- Add a generic `catch (e)` block to `_signInOrCreateAccount` to handle database exceptions (like RLS violations) and provide feedback to the user.

#### [MODIFY] [authentication_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/auth/authentication_widget.dart)
- Update `_handleSignIn` and `_handleCreateAccount` to only navigate to the initialization screen if authentication was successful (i.e., the returned user is not null).

## Verification Plan

### Manual Verification
- Attempt to sign up as a "Business Owner" and verify that the user record is created in the `public.users` table.
- Attempt to sign in with incorrect credentials and verify that the app does not navigate to the home screen.
- Verify that error snackbars are shown for database-related errors.
