import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/data/datasources/supabase_marketplace_maps.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/service_provider_profile.dart';
import 'package:degloor_one/shared/service_request.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

/// Data access for the service marketplace. Widgets should go through
/// [ServiceMarketplaceService].
/// Table-backed implementation; Java leftover reads live on
/// [ServiceMarketplaceService].
class ServiceMarketplaceRepository {
  Future<List<ServiceCategory>> categories() async {
    final rows = await ServiceCategoriesTable().queryRows(
      queryFn: (q) => q.order('name', ascending: true),
    );
    return rows.map(serviceCategoryFromRow).toList();
  }

  Future<List<ServiceProviderCard>> providers({
    String? categoryId,
    PageQuery page = const PageQuery(),
  }) async {
    if (kUseShowcaseData) {
      return ShowcaseCatalog.serviceProviders(
        categoryId: categoryId,
        limit: page.limit,
        offset: page.offset,
      ).map(ServiceProviderCard.fromJoin).toList();
    }

    var query = SupaFlow.client
        .from('service_providers')
        .select('*, users(full_name, avatar_url), service_categories(name)');
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final response =
        await query.order('created_at', ascending: false).range(page.from, page.to);
    return List<Map<String, dynamic>>.from(response)
        .map(ServiceProviderCard.fromJoin)
        .toList();
  }

  Future<ServiceProviderCard?> providerById(String id) async {
    if (kUseShowcaseData) {
      final row = ShowcaseCatalog.serviceProvider(id);
      return row == null ? null : ServiceProviderCard.fromJoin(row);
    }
    final row = await SupaFlow.client
        .from('service_providers')
        .select(
          '*, users(full_name, avatar_url, phone_number), service_categories(name)',
        )
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return ServiceProviderCard.fromJoin(Map<String, dynamic>.from(row));
  }

  Future<ServiceProviderProfile?> forUser(String userId) async {
    final rows = await ServiceProvidersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId),
      limit: 1,
    );
    return rows.isEmpty ? null : serviceProviderProfileFromRow(rows.first);
  }

  Future<ServiceProviderProfile> insertProvider(Map<String, dynamic> data) async {
    final row = await ServiceProvidersTable().insert(data);
    return serviceProviderProfileFromRow(row);
  }

  Future<ServiceRequest> insertRequest(Map<String, dynamic> data) async {
    final row = await ServiceRequestsTable().insert(data);
    return serviceRequestFromRow(row);
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await ServiceRequestsTable().update(
      data: {'status': status},
      matchingRows: (q) => q.eq('id', requestId),
    );
  }

  Stream<List<ServiceRequest>> watchForProvider(String providerId) {
    return ServiceRequestsTable()
        .stream(
          primaryKey: 'id',
          queryFn: (q) => q.eq('provider_id', providerId),
        )
        .map((rows) => rows.map(serviceRequestFromRow).toList());
  }
}
