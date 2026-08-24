# Implementation Plan - Convert Backend Service Logic to Java

The goal is to mirror the logic from the Dart `DiscoveryService` into the Java Spring Boot backend. This involves creating a unified search endpoint that aggregates results from businesses, products, services, and jobs.

## Proposed Changes

### [Discovery Component]

#### [NEW] [DiscoveryDtos.java](file:///C:/Users/USER/StudioProjects/Degloor-One/degloor-one-backend/src/main/java/com/degloor/one/discovery/dto/DiscoveryDtos.java)
- Define `MasterSearchResponse` to aggregate results.
- Define `ShopInsightsResponse` for business analytics.

#### [NEW] [DiscoveryService.java](file:///C:/Users/USER/StudioProjects/Degloor-One/degloor-one-backend/src/main/java/com/degloor/one/discovery/service/DiscoveryService.java)
- Implement `masterSearch` logic:
  - Aggregate `BusinessResponse` from `BusinessService`.
  - Aggregate `ProductResponse` from `ProductService`.
  - Aggregate `ProviderResponse` from `MarketplaceService`.
  - Aggregate `JobResponse` from `JobService`.
- Implement `insightsFor` logic:
  - Combine review counts and analytic events.

#### [NEW] [DiscoveryController.java](file:///C:/Users/USER/StudioProjects/Degloor-One/degloor-one-backend/src/main/java/com/degloor/one/discovery/controller/DiscoveryController.java)
- Expose `GET /api/v1/discovery/search` for unified search.
- Expose `GET /api/v1/discovery/insights/{businessId}`.

## Verification Plan

### Automated Tests
- Create unit tests for `DiscoveryService` in `DiscoveryServiceTest.java`.
- Mock dependency services (`BusinessService`, `ProductService`, etc.) to verify aggregation.

### Manual Verification
- Use Postman or `curl` to call the new discovery endpoints and verify JSON structure matches Dart expectation.
