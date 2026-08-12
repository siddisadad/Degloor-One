# Task List

## Phase 1: Authentication & Roles
- [ ] Remove client-side role control in `SupabaseAuthManager`
- [ ] Update `AuthenticationWidget` and other UI to remove role parameters
- [ ] Tighten `users` table RLS policies in `schema.sql`

## Phase 2: Security & RLS
- [ ] Audit all tables for proper RLS policies
- [ ] Implement `place_order` RPC for secure transactions and inventory management
- [ ] Tighten `businesses` table update policy to protect `is_verified`

## Phase 3: Bug Fixes & Cleanup
- [ ] Fix `InitialRedirectWidget` location timeout/error handling
- [ ] Remove hardcoded "fake" data from `AdminControlPanel` and `BusinessDashboard`
- [ ] Remove duplicate "Open Now" filtering in search results

## Phase 4: Analytics & Error Handling
- [ ] Consolidate analytics services into `analytics.dart`
- [ ] Implement centralized error handling/logging utility
- [ ] Replace `print()`/`debugPrint()` with the new logging utility in production paths
