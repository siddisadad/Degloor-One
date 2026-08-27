# Business Dashboard Data Integration & Linking

This plan restores real-time data integration to the Business Dashboard and links the missing "Manage Jobs" and "Detailed Insights" features.

## Proposed Changes

### Business Dashboard

#### [MODIFY] [business_dashboard_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_dashboard_widget.dart)
- Restore `_fetchData()` to load the business profile and analytics events.
- Bind `StatCardWidget` values to live analytics counts:
    - Profile Views
    - Call Clicks
    - WhatsApp Clicks
    - Directions Clicks
- Link "Manage Jobs" and "Business Insights" tiles to their respective screens.
- Implement dynamic `_calculateCompleteness()` logic.
- Fix FAB to navigate to `EditBusinessProfile` with the current business data.

## Verification Plan

### Manual Verification
- Verify that the counts in the "Insights" grid update after interacting with the business profile as a customer.
- Verify that all management tiles navigate correctly.
