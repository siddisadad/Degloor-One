import 'package:degloor_one/backend/native_service_bridge.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/service_marketplace_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/marketplace_api.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/service_provider_profile.dart';
import 'package:degloor_one/shared/service_request.dart';
import 'package:degloor_one/shared/rpc_row.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

class ServiceRequestStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
  static const completed = 'completed';

  static const all = {pending, accepted, declined, completed};
}

class ServiceRequestActions {
  const ServiceRequestActions({
    required this.canAccept,
    required this.canDecline,
    required this.canComplete,
  });

  final bool canAccept;
  final bool canDecline;
  final bool canComplete;

  String get acceptStatus => ServiceRequestStatus.accepted;
  String get declineStatus => ServiceRequestStatus.declined;
  String get completeStatus => ServiceRequestStatus.completed;

  factory ServiceRequestActions.forStatus(String? status) {
    final current = (status ?? ServiceRequestStatus.pending).toLowerCase();
    return ServiceRequestActions(
      canAccept: current == ServiceRequestStatus.pending,
      canDecline: current == ServiceRequestStatus.pending,
      canComplete: current == ServiceRequestStatus.accepted,
    );
  }
}

class ServiceMarketplaceService {
  ServiceMarketplaceService({ServiceMarketplaceRepository? repository})
      : _repository = repository ?? ServiceMarketplaceRepository();

  final ServiceMarketplaceRepository _repository;

  static final instance = ServiceMarketplaceService();

  ServiceRequestActions requestActions(String? status) =>
      ServiceRequestActions.forStatus(status);

  Future<List<ServiceCategory>> categories() async {
    if (!kUseShowcaseData) {
      final native = await NativeServiceBridge.getCategories();
      if (native.isNotEmpty) return native;
    }
    final rows = await _repository.categories();
    return rows.map(ServiceCategory.fromRow).toList();
  }

  Future<PageResult<ServiceProviderCard>> providers({
    String? categoryId,
    PageQuery page = const PageQuery(),
  }) async {
    if (!kUseShowcaseData) {
      final native = await NativeServiceBridge.getProviders(categoryId);
      if (native.isNotEmpty) {
        return PageResult(items: native, hasMore: false);
      }
    }

    final rows = await _repository.providers(
      categoryId: categoryId,
      page: page,
    );
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  Future<ServiceProviderProfile?> forUser(String userId) async {
    final row = await _repository.forUser(userId);
    return row == null ? null : ServiceProviderProfile.fromRow(row);
  }

  Future<ServiceProviderProfile> register({
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
    if (JavaApiConfig.enabled) {
      final categories = await MarketplaceApi.categories();
      if (!categories.any((row) => '${row['id']}' == categoryId)) {
        throw Exception('Please select a service category');
      }
      final providers = await MarketplaceApi.providers();
      if (providers.any((row) => '${row['userId'] ?? ''}' == userId)) {
        throw Exception('You already have a service profile');
      }
      return ServiceProviderProfile.fromJson(
        await MarketplaceApi.register(
          categoryId: categoryId,
          bio: trimmedBio,
          hourlyRate: rate,
          experienceYears: years,
        ),
      );
    }
    final categories = await _repository.categories();
    if (!categories.any((row) => row.id == categoryId)) {
      throw Exception('Please select a service category');
    }
    final existing = await _repository.forUser(userId);
    if (existing != null) {
      throw Exception('You already have a service profile');
    }
    final row = await _repository.insertProvider({
      'user_id': userId,
      'category_id': categoryId,
      'experience_years': years,
      'hourly_rate': rate,
      'bio': trimmedBio,
      'is_verified': false,
    });
    return ServiceProviderProfile.fromRow(row);
  }

  Future<ServiceProviderCard?> providerById(String id) =>
      _repository.providerById(id);

  Stream<List<ServiceRequest>> watchForProvider(String providerId) {
    return _repository
        .watchForProvider(providerId)
        .map((rows) => rows.map(ServiceRequest.fromRow).toList());
  }

  Future<ServiceRequest> createRequest({
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

    if (JavaApiConfig.enabled) {
      try {
        return ServiceRequest.fromJson(
          await MarketplaceApi.createRequest(
            providerId: providerId,
            description: trimmed,
            scheduledAt: scheduledAt,
          ),
        );
      } on JavaApiException catch (error) {
        if (error.code == 'PROVIDER_NOT_FOUND' || error.code.contains('404')) {
          throw Exception('Service provider not found');
        }
        rethrow;
      }
    }

    if (kUseShowcaseData) {
      final row = await _repository.insertRequest({
        'user_id': userId,
        'provider_id': providerId,
        'description': trimmed,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': ServiceRequestStatus.pending,
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
      return ServiceRequest.fromRow(row);
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
    return ServiceRequest.fromRow(ServiceRequestsRow(row));
  }

  Future<void> updateStatus({
    required String requestId,
    required String nextStatus,
    required String actorUserId,
  }) async {
    final status = nextStatus.trim().toLowerCase();
    if (!ServiceRequestStatus.all.contains(status)) {
      throw Exception('Invalid service request status');
    }

    if (JavaApiConfig.enabled) {
      try {
        await MarketplaceApi.updateStatus(
          requestId: requestId,
          status: status,
        );
        return;
      } on JavaApiException catch (error) {
        if (error.code == 'FORBIDDEN') {
          throw Exception('Not allowed to update this request');
        }
        if (error.code == 'REQUEST_NOT_FOUND' || error.code.contains('404')) {
          throw Exception('Service request not found');
        }
        rethrow;
      }
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
      ServiceRequestStatus.pending => {
          ServiceRequestStatus.accepted,
          ServiceRequestStatus.declined,
        },
      ServiceRequestStatus.accepted => {ServiceRequestStatus.completed},
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
