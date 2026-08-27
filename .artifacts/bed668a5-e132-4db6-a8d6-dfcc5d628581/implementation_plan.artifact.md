# DEGLOOR ONE - Phase 1 Final Hardening & Production Readiness Plan

This plan outlines the steps to bring the DEGLOOR ONE application to production-ready Phase 1 pilot quality.

## User Review Required

> [!IMPORTANT]
> The search radius options will be restricted to [2, 5, 10, 15, 25] KM as per the Phase 1 requirement.
> The default radius will be strictly set to 10 KM.

> [!WARNING]
> Duplicate "Open Now" status queries will be removed. Flutter will rely on the Supabase RPC `search_businesses_in_radius` as the single authoritative source for open status.

## Proposed Changes

### Database & Backend (Supabase)

#### [MODIFY] [schema.sql](file:///A:/Workspace/Degloor-One/scratch/schema.sql)
- Enhance `search_businesses_in_radius` RPC to return `is_open` and `distance_km` reliably.
- Audit and harden RLS policies for all tables, especially `businesses`, `reviews`, and `business_analytics`.
- Ensure geographic indexes are correctly applied.
- Implement `is_business_open` logic correctly considering 'Asia/Kolkata' timezone.

#### [NEW] [business_events_migration.sql](file:///A:/Workspace/Degloor-One/scratch/business_events_migration.sql)
- Create a dedicated migration for the lightweight analytics event system.

### Search Architecture

#### [MODIFY] [search_results_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/search/search_results_widget.dart)
- Remove manual `getMultipleBusinessesOpenStatus` call.
- Use `business.isOpen` and `business.distanceKm` directly.
- Standardize distance formatting: `< 1 KM -> metres`, `>= 1 KM -> one decimal kilometre`.

#### [MODIFY] [customer_home_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/home/customer_home_widget.dart)
- Remove duplicate open status fetching.
- Sync radius selection options with Phase 1 requirements.

### Location & Radius

#### [MODIFY] [app_state.dart](file:///A:/Workspace/Degloor-One/lib/app_state.dart)
- Ensure default radius is 10.0.
- Validate radius values against allowed options.

#### [MODIFY] [location_service.dart](file:///A:/Workspace/Degloor-One/lib/backend/location_service.dart)
- Implement timeout handling (e.g., 10s) for GPS.
- Add fallback to last known location or manual selection.

### Business Dashboard & Analytics

#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Remove Phase 2 metrics (Revenue, Orders, etc.).
- Integrate with new `business_analytics` table for real-time insights (Profile Views, Call Clicks, etc.).

### UI/UX & Hardening

#### [MODIFY] [business_card_widget.dart](file:///A:/Workspace/Degloor-One/lib/components/business_card/business_card_widget.dart)
#### [MODIFY] [business_card800502e0_widget.dart](file:///A:/Workspace/Degloor-One/lib/components/business_card800502e0/business_card800502e0_widget.dart)
- Standardize display of distance and open status.
- Ensure consistent styling according to brand guidelines.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no regressions.
- Run existing widget tests.

### Manual Verification
- **Location**: Test with GPS enabled/disabled and permission denied flows.
- **Search**: Verify radius filtering and search relevance.
- **Security**: Attempt unauthorized modifications to other businesses or reviews.
- **Localization**: Verify Marathi and Hindi text display on multiple screen sizes.
