import 'package:degloor_one/backend/supabase/database/tables/service_categories_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/service_providers_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/service_requests_table.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/service_provider_profile.dart';
import 'package:degloor_one/shared/service_request.dart';

ServiceCategory serviceCategoryFromRow(ServiceCategoriesRow row) {
  final rawCreated = row.data['created_at'];
  DateTime? createdAt;
  if (rawCreated is DateTime) {
    createdAt = rawCreated;
  } else if (rawCreated != null) {
    createdAt = DateTime.tryParse('$rawCreated');
  }
  return ServiceCategory(
    id: row.id,
    name: row.name,
    iconName: row.iconName,
    createdAt: createdAt,
  );
}

ServiceProviderProfile serviceProviderProfileFromRow(ServiceProvidersRow row) {
  return ServiceProviderProfile(
    id: row.id,
    isVerified: row.isVerified,
    createdAt: row.createdAt,
    userId: row.userId,
    categoryId: row.categoryId,
    bio: row.bio,
    hourlyRate: row.hourlyRate,
    experienceYears: row.experienceYears,
  );
}

ServiceRequest serviceRequestFromRow(ServiceRequestsRow row) {
  return ServiceRequest(
    id: row.id,
    createdAt: row.createdAt,
    userId: row.userId,
    providerId: row.providerId,
    description: row.description,
    status: row.status,
    scheduledAt: row.scheduledAt,
  );
}
