# DEGLOOR ONE - Pilot Pre-flight Checklist

This checklist must be completed by the Release Manager before the Degloor pilot launch.

## 1. Environment & Infrastructure
- [ ] **Supabase Production Project**: Ensure `lib/backend/supabase/supabase.dart` is pointed to the production instance (not dev/staging).
- [ ] **Database Seed**: Verify `cities` and `business_categories` are seeded in the production DB.
- [ ] **Storage Buckets**: Ensure `business-photos` bucket exists and has public read access.

## 2. API Keys & Secrets
- [ ] **Google Maps (Android)**: Verify `GOOGLE_MAPS_API_KEY` is set in `local.properties` on the build machine.
- [ ] **Google Maps (iOS)**: Verify `GOOGLE_MAPS_API_KEY` is set in the `.xcconfig` on the build machine.
- [ ] **Supabase Key**: Move Supabase URL/AnonKey to CI/CD environment variables or a secure configuration file.
- [ ] **Password reset redirects**: Allow `degloorone://degloorone.com/resetPassword` and the production web `/resetPassword` URL in Supabase Auth URL Configuration.

## 3. Data Integrity & Security
- [ ] **RLS Verification**: Run a manual check on the `users` table to ensure the `role` field cannot be updated by normal users via the API.
- [ ] **Admin Account**: Manually set at least one user's role to `'admin'` in the Supabase dashboard to enable the Admin Panel.
- [ ] **Verification Workflow**: Test the verification of one mock business from the Admin Panel to ensure it then appears in search.

## 4. Local User Experience
- [ ] **Localization**: Verify all Marathi/Hindi translations in `lib/l10n/` are correct for the Degloor dialect.
- [ ] **WhatsApp Formatting**: Test clicking the WhatsApp button on a business with a 10-digit number to ensure it redirects to `wa.me/91...`.
- [ ] **Search Radius**: Confirm the default 10 KM radius shows the expected businesses for the Degloor town center.

## 5. Performance
- [ ] **Index Check**: Verify `idx_businesses_location` exists in production for fast spatial searches.
- [ ] **Cold Start**: Verify the splash screen doesn't hang (currently set to 1s delay).

---
**Released Recommendation**: PILOT READY
