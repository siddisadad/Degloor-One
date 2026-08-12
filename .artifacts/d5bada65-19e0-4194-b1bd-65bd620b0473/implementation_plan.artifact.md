# Implementation Plan - Priority 2 Tasks

This plan covers the Priority 2 tasks for the DEGLOOR ONE app, focusing on simplifying the UI, improving UX, and removing hardcoded dependencies.

## User Review Required

> [!IMPORTANT]
> The simplification of the Business Dashboard and Admin Panel will involve reorganization of menu items. Please review the proposed groupings below.

> [!NOTE]
> Improving location permission UX will involve adding an explanatory bottom sheet before requesting system permissions.

## Proposed Changes

---

### 1. Simplify Business Dashboard & Admin Panel
Group actions logically and use a more compact layout to reduce scrolling.

#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Group "Catalogue", "Business Hours", and "Edit Profile" into a "Store Management" section.
- Group "Add Photos", "Create Offer", and "Reviews" into a "Marketing & Growth" section.
- Use a 2x2 grid for stats instead of just rows if applicable.

#### [MODIFY] [admin_control_panel_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/admin/admin_control_panel_widget.dart)
- Introduce a tabbed view or card-based navigation for "Verification Queues", "Complaints", and "System Config".
- Current layout is a long list which makes it hard to manage.

---

### 2. Improve Location Permission UX
Add a "Pre-permission" dialog to explain *why* the app needs location (e.g., "To find businesses within your radius and calculate accurate delivery fees").

#### [MODIFY] [location_service.dart](file:///A:/Workspace/Degloor-One/lib/backend/location_service.dart)
- Add a check for permission status and return a custom enum/status.
- Avoid printing to console; use a callback or throw controlled exceptions.

#### [NEW] [location_explanation_dialog.dart](file:///A:/Workspace/Degloor-One/lib/components/location_explanation_dialog.dart)
- A reusable component to show before calling `Geolocator.requestPermission()`.

---

### 3. Remove Production Dummy-Data Dependency & Profile Completeness
Make the "Completeness" card dynamic by checking fields in the `BusinessesRow`.

#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Implement `_calculateCompleteness()` logic:
    - Business Name (10%)
    - Description (15%)
    - Category (10%)
    - WhatsApp Number (10%)
    - Address (15%)
    - Latitude/Longitude (20%)
    - Images (20%)
- Pass these values to `CompletenessCardWidget`.

#### [DELETE] [dummy_data.dart](file:///A:/Workspace/Degloor-One/lib/shared/dummy_data.dart)
- Remove the file if it's truly unused after verification.

---

### 4. Optimize Search RPC
Improve the performance and accuracy of the search function.

#### [MODIFY] [schema.sql](file:///A:/Workspace/Degloor-One/scratch/schema.sql)
- Ensure GIST index on `businesses.location`.
- Update `search_businesses_in_radius` to handle empty search terms more efficiently.
- Consider adding `pg_trgm` extension for better `ILIKE` performance if datasets grow.

---

### 5. Add Proper Empty/Error States
Standardize empty and error states across list views.

#### [NEW] [empty_state_view.dart](file:///A:/Workspace/Degloor-One/lib/components/empty_state_view.dart)
- A reusable component with an icon, title, and optional CTA button.

#### [MODIFY] [customer_home_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/home/customer_home_widget.dart)
#### [MODIFY] [search_results_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/search/search_results_widget.dart)
- Replace basic `Text('No results')` with `EmptyStateView`.

## Verification Plan

### Automated Tests
- Run `flutter test` (if tests exist) to ensure no regressions.
- Verify RPC call logic via Supabase SQL Editor.

### Manual Verification
1. **Business Dashboard**: Verify that completeness percentage changes when updating profile fields.
2. **Location**: Trigger location request and verify the explanation dialog appears.
3. **Search**: Perform searches with various terms and radii; verify results are accurate and fast.
4. **Empty States**: Filter businesses/products to get no results and verify the new empty state UI.
