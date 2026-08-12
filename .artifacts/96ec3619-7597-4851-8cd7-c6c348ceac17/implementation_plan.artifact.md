# Implementation Plan - Fix Project Issues

Addressing `flutter analyze` deprecations and implementing the "Locate Me" functionality in the business registration flow.

## Proposed Changes

### Cart Feature

#### [MODIFY] [cart_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/cart/cart_widget.dart)
- Wrap `RadioListTile`s in a `RadioGroup` widget to address deprecation warnings for `groupValue` and `onChanged`.
- Remove `groupValue` and `onChanged` from individual `RadioListTile`s.

### Business Registration Feature

#### [MODIFY] [business_registration_widget.dart](file:///A:/Workspace/Degloor-One/lib/features/businesses/business_registration_widget.dart)
- Implement `onTap` logic for the "Locate Me" button to update the map center to the user's current location.
- Use `LocationService.updateCurrentLocation()` and animate the map camera.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify that all deprecations and errors are resolved.

### Manual Verification
- Test "Locate Me" button in the Business Registration screen on a device/emulator.
- Verify that Radio buttons in the Cart screen still work as expected.
