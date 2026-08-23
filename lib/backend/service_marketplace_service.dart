import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/service_marketplace_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

const _allowedRequestStatuses = {
  'pending',
  'accepted',
  'declined',
  'completed',
};

class ServiceMarketplaceService {
  ServiceMarketplaceService({ServiceMarketplaceRepository? repository})
      : _repository = repository ?? ServiceMarketplaceRepository();

  final ServiceMarketplaceRepository _repository;

  static final instance = ServiceMarketplaceService();

  Future<List<ServiceCategoriesRow>> categories() => _repository.categories();

  Future<PageResult<Map<String, dynamic>>> providers({
    String? categoryId,
    PageQuery page = const PageQuery(),
  }) async {
    final rows = await _repository.providers(
      categoryId: categoryId,
      page: page,
    );
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  Future<ServiceProvidersRow?> forUser(String userId) =>
      _repository.forUser(userId);

  Future<ServiceProvidersRow> register({
    required String userId,
    required String categoryId,
    required String experienceYears,
    required String hourlyRate,
    required String bio,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to register as a provider');
    }
    if (categoryId.isEmpty) {
      throw Exception('Please select a service category');
    }
    final trimmedBio = bio.trim();
    if (trimmedBio.isEmpty) {
      throw Exception('Please write a short bio');
    }
    final years = int.tryParse(experienceYears.trim());
    if (years == null || years < 0) {
      throw Exception('Please enter your years of experience');
    }
    final rate = double.tryParse(hourlyRate.trim());
    if (rate == null || rate <= 0) {
      throw Exception('Please enter your hourly rate');
    }
    final categories = await _repository.categories();
    if (!categories.any((row) => row.id == categoryId)) {
      throw Exception('Please select a service category');
    }
    final existing = await _repository.forUser(userId);
    if (existing != null) {
      throw Exception('You already have a service profile');
    }
    return _repository.insertProvider({
      'user_id': userId,
      'category_id': categoryId,
      'experience_years': years,
      'hourly_rate': rate,
      'bio': trimmedBio,
      'is_verified': false,
    });
  }

  Future<Map<String, dynamic>?> providerById(String id) =>
      _repository.providerById(id);

  Stream<List<ServiceRequestsRow>> watchForProvider(String providerId) =>
      _repository.watchForProvider(providerId);

  Future<ServiceRequestsRow> createRequest({
    required String userId,
    required String providerId,
    required String description,
    required DateTime scheduledAt,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Please sign in to request a service');
    }
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      throw Exception('Please enter a description');
    }

    if (kUseShowcaseData) {
      final row = await _repository.insertRequest({
        'user_id': userId,
        'provider_id': providerId,
        'description': trimmed,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': 'pending',
      });
      final providers = ShowcaseCatalog.query(
        'service_providers',
        ShowcaseQuery()..eq('id', providerId),
      );
      final providerUserId =
          providers.isEmpty ? null : providers.first['user_id']?.toString();
      if (providerUserId != null && providerUserId.isNotEmpty) {
        await NotificationService.sendNotification(
          userId: providerUserId,
          title: 'New service request',
          message: 'Someone requested your service in Degloor.',
          type: 'service_request',
        );
      }
      return row;
    }

    final response = await SupaFlow.client.rpc(
      'create_service_request',
      params: {
        'p_provider_id': providerId,
        'p_description': trimmed,
        'p_scheduled_at': scheduledAt.toIso8601String(),
      },
    );
    final row = asRpcRow(response);
    if (row == null) {
      throw Exception('Failed to send the service request');
    }
    return ServiceRequestsRow(row);
  }

  Future<void> updateStatus({
    required String requestId,
    required String nextStatus,
    required String actorUserId,
  }) async {
    final status = nextStatus.trim().toLowerCase();
    if (!_allowedRequestStatuses.contains(status)) {
      throw Exception('Invalid service request status');
    }

    if (kUseShowcaseData) {
      _updateShowcaseStatus(
        requestId: requestId,
        nextStatus: status,
        actorUserId: actorUserId,
      );
      return;
    }

    await SupaFlow.client.rpc(
      'update_service_request_status',
      params: {
        'p_request_id': requestId,
        'p_status': status,
      },
    );
  }

  static void _updateShowcaseStatus({
    required String requestId,
    required String nextStatus,
    required String actorUserId,
  }) {
    final requests = ShowcaseCatalog.query(
      'service_requests',
      ShowcaseQuery()..eq('id', requestId),
    );
    if (requests.isEmpty) {
      throw Exception('Service request not found');
    }
    final request = requests.first;
    final providers = ShowcaseCatalog.query(
      'service_providers',
      ShowcaseQuery()..eq('id', request['provider_id']),
    );
    if (providers.isEmpty || providers.first['user_id'] != actorUserId) {
      throw Exception('Not allowed to update this request');
    }

    final current = '${request['status']}'.toLowerCase();
    final allowed = switch (current) {
      'pending' => {'accepted', 'declined'},
      'accepted' => {'completed'},
      _ => <String>{},
    };
    if (!allowed.contains(nextStatus)) {
      throw Exception('Invalid status transition from $current to $nextStatus');
    }

    ShowcaseCatalog.update(
      'service_requests',
      {'status': nextStatus},
      ShowcaseQuery()..eq('id', requestId),
    );
    NotificationService.notifyServiceRequestUpdate(
      userId: '${request['user_id']}',
      status: nextStatus,
    );
  }
}
