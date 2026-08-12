# Implementation Plan - Phase 1 Feature Cleanup and Verification

This plan outlines the steps to remove Products, Cart, Orders, and Delivery features from the Phase 1 UI of the Degloor-One app, fix review eligibility, and verify Supabase RLS and authorization logic.

## Proposed Changes

### [Search]
#### [MODIFY] [search_results_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/search/search_results_widget.dart)
- Remove `_productResultsFuture` and related logic.
- Remove the "Products found" section from the UI.

### [Customer Home]
#### [MODIFY] [customer_home_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/home/customer_home_widget.dart)
- Remove the Cart icon button from the top right.

### [User Profile]
#### [MODIFY] [user_profile_reports_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/profile/user_profile_reports_widget.dart)
- Hide the "Order History" section.
- Hide the "Switch to Delivery Mode" profile option.

### [Business Profile & Catalogue]
#### [MODIFY] [business_catalogue_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_catalogue_widget.dart)
- Remove the Cart icon button.
- Hide "Add to Cart" functionality (or the entire shopping cart logic).

#### [MODIFY] [business_profile_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_profile_widget.dart)
- Remove the Cart icon button.
- Relax review eligibility: Remove the requirement for a completed 'delivered' order. Allow any logged-in user to write a review for Phase 1.

### [Business Dashboard]
#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Hide "Manage Orders" button.
- Hide "Total Orders" and "Pending Orders" statistics.

### [Verification]
- Review Supabase RLS policies in `schema.sql`.
- Review business ownership and admin authorization logic in `authentication_widget.dart` and `auth_util.dart`.

## Verification Plan

### Automated Tests
- Since this is a UI cleanup, manual verification on the device/emulator is preferred.

### Manual Verification
- Verify that Products do not appear in search results.
- Verify that Cart icons are gone from Home, Search, Business Catalogue, and Business Profile.
- Verify that Order History and Delivery Switch are gone from the User Profile.
- Verify that Manage Orders and Order stats are gone from the Business Dashboard.
- Verify that a logged-in user can write a review without having a previous order.
- Verify that Business Owners can still access their dashboard and Admins can access theirs.
