# DEGLOOR ONE - Phase 1 Pilot Manual Test Matrix

This document outlines the test cases required to verify the production readiness of the DEGLOOR ONE application.

## 1. Onboarding & Authentication
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 1.1 | New Customer Signup | User is created in Supabase with 'customer' role and redirected to Home. | Critical |
| 1.2 | Business Owner Signup | User signs up, registers business, role becomes 'business_owner', redirected to Dashboard. | Critical |
| 1.3 | Role Redirection | Logged in Admin lands on Control Panel; Owner on Dashboard; Customer on Home. | High |
| 1.4 | Sign Out | Session is cleared, user is redirected to Authentication screen. | High |

## 2. Customer Discovery & Search
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 2.1 | Radius Filtering | Results update correctly when switching between 2km, 5km, 10km, 25km. | Critical |
| 2.2 | Category Filter | Only businesses belonging to the selected category are displayed. | High |
| 2.3 | "Open Now" Toggle | Results only show businesses whose current time falls within their set hours. | High |
| 2.4 | Distance Formatting | `< 1km` shows in meters (e.g., 450m); `>= 1km` shows with 1 decimal (e.g., 1.2km). | Medium |

## 3. Business Dashboard & Management
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 3.1 | Analytics Accuracy | "Views" count increments after visiting the public profile; "Calls" increments on click. | High |
| 3.2 | Business Hours Save | Saving hours for all 7 days persists correctly (no crashes on new day initialization). | Critical |
| 3.3 | Catalogue Management | Adding a product with image and price appears instantly in the customer view. | Critical |
| 3.4 | Profile Completeness | Percentage increases as Description, Images, and Location are added. | Medium |

## 4. Order & Cart Flow
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 4.1 | Multi-Business Cart | System prevents adding products from two different businesses to the same cart. | High |
| 4.2 | Delivery Fee Calc | Fee updates based on distance: ₹20 base up to 3km, then ₹10 per additional km. | Critical |
| 4.3 | Order Lifecycle | Status changes (Pending -> Accepted -> Ready -> Delivered) reflect in real-time for both. | Critical |

## 5. Admin Control Panel
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 5.1 | Business Verification | Approving a business in Admin Panel sets `is_verified` and sends notification to owner. | Critical |
| 5.2 | Complaint Resolution | Resolving a complaint sends a notification to the reporting customer. | High |

## 6. System & Edge Cases
| ID | Test Case | Expected Result | Priority |
|:---|:---|:---|:---|
| 6.1 | GPS Disabled | App shows `EmptyStateView` with "Enable Location" button; fallback to last known works. | High |
| 6.2 | Language Switch | Switching to Marathi/Hindi updates all core UI labels (Categories, Tabs, Buttons). | High |
| 6.3 | No Results State | `EmptyStateView` appears with relevant suggestions when no businesses are in radius. | Medium |
