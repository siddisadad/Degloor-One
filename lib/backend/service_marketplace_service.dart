import 'package:degloor_one/backend/native_service_bridge.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/repositories/service_marketplace_repository.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/api/api_client.dart';
import 'package:degloor_one/core/api/marketplace_api.dart';
import 'package:degloor_one/data/datasources/supabase_marketplace_maps.dart';
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
    if (JavaApiConfig.enabled) {
      final rows = await MarketplaceApi.categories();
      return [for (final row in rows) ServiceCategory.fromJson(row)];
    }
    if (!kUseShowcaseData) {
      final native = await NativeServiceBridge.getCategories();
      if (native.isNotEmpty) return native;
      try {
        final live = await _repository.categories();
        if (live.isNotEmpty) return live;
      } catch (_) {}
      return _showcaseCategories();
    }
    return _repository.categories();
  }

  Future<PageResult<ServiceProviderCard>> providers({
    String? categoryId,
    PageQuery page = const PageQuery(),
  }) async {
    if (JavaApiConfig.enabled) {
      final names = await _javaCategoriesById();
      final rows = await MarketplaceApi.providers(categoryId: categoryId);
      final items = [
        for (final row in rows)
          ServiceProviderCard.fromJson(
            row,
            category: names['${row['categoryId'] ?? ''}'],
          ),
      ];
      final paged = items.skip(page.offset).take(page.limit).toList();
      return PageResult(
        items: paged,
        hasMore: page.offset + paged.length < items.length,
      );
    }
    if (!kUseShowcaseData) {
      var rows = <ServiceProviderCard>[];
      final native = await NativeServiceBridge.getProviders(categoryId);
      if (native.isNotEmpty) {
        rows = native;
      } else {
        try {
          rows = await _repository.providers(
            categoryId: categoryId,
            page: page,
          );
        } catch (_) {}
      }
      final extra = _locallyInsertedProviders(categoryId)
          .where((card) => rows.every((row) => row.id != card.id));
      final items = [...rows, ...extra];
      return PageResult(
        items: items,
        hasMore: native.isEmpty && rows.length >= page.limit,
      );
    }

    final rows = await _repository.providers(
      categoryId: categoryId,
      page: page,
    );
    return PageResult(items: rows, hasMore: rows.length >= page.limit);
  }

  Future<ServiceProviderProfile?> forUser(String userId) async {
    if (JavaApiConfig.enabled) {
      if (userId.isEmpty) return null;
      final rows = await MarketplaceApi.providers();
      for (final row in rows) {
        final profile = ServiceProviderProfile.fromJson(row);
        if (profile.userId == userId) return profile;
      }
      return null;
    }
    if (kUseShowcaseData) {
      return _repository.forUser(userId);
    }
    try {
      final live = await _repository.forUser(userId);
      if (live != null) return live;
    } catch (_) {}
    return _showcaseProfileForUser(userId);
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
    final categories = await this.categories();
    if (!categories.any((row) => row.id == categoryId)) {
      throw Exception('Please select a service category');
    }
    final existing = await forUser(userId);
    if (existing != null) {
      throw Exception('You already have a service profile');
    }
    final data = {
      'user_id': userId,
      'category_id': categoryId,
      'experience_years': years,
      'hourly_rate': rate,
      'bio': trimmedBio,
      'is_verified': false,
    };
    if (kUseShowcaseData) {
      return _repository.insertProvider(data);
    }
    try {
      return await _repository.insertProvider(data);
    } catch (_) {
      return _insertShowcaseProvider(data);
    }
  }

  Future<ServiceProviderCard?> providerById(String id) async {
    if (JavaApiConfig.enabled) {
      if (id.isEmpty) return null;
      try {
        final json = await MarketplaceApi.provider(id);
        final names = await _javaCategoriesById();
        return ServiceProviderCard.fromJson(
          json,
          category: names['${json['categoryId'] ?? ''}'],
        );
      } on JavaApiException catch (error) {
        if (error.code == 'PROVIDER_NOT_FOUND' || error.code.contains('404')) {
          return null;
        }
        rethrow;
      }
    }
    if (kUseShowcaseData) {
      return _repository.providerById(id);
    }
    try {
      final live = await _repository.providerById(id);
      if (live != null) return live;
    } catch (_) {}
    final row = ShowcaseCatalog.serviceProvider(id);
    return row == null ? null : ServiceProviderCard.fromJoin(row);
  }

  Stream<List<ServiceRequest>> watchForProvider(String providerId) {
    if (JavaApiConfig.enabled) {
      return Stream.fromFuture(_javaInbox(providerId));
    }
    return _repository.watchForProvider(providerId);
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
      final request = await _repository.insertRequest({
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
      return request;
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
    return serviceRequestFromRow(ServiceRequestsRow(row));
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

  static List<ServiceCategory> _showcaseCategories() {
    return [
      for (final row
          in ShowcaseCatalog.query('service_categories', ShowcaseQuery()))
        serviceCategoryFromRow(ServiceCategoriesRow(row)),
    ];
  }

  static ServiceProviderProfile _insertShowcaseProvider(
    Map<String, dynamic> data,
  ) {
    return _profileFromShowcase(
      ShowcaseCatalog.insert('service_providers', data),
    );
  }

  static ServiceProviderProfile? _showcaseProfileForUser(String userId) {
    final rows = ShowcaseCatalog.query(
      'service_providers',
      ShowcaseQuery()..eq('user_id', userId),
    );
    if (rows.isEmpty) return null;
    return _profileFromShowcase(rows.first);
  }

  static ServiceProviderProfile _profileFromShowcase(
    Map<String, dynamic> row,
  ) {
    return serviceProviderProfileFromRow(ServiceProvidersRow(row));
  }

  static List<ServiceProviderCard> _locallyInsertedProviders(
    String? categoryId,
  ) {
    return [
      for (final row in ShowcaseCatalog.serviceProviders(categoryId: categoryId))
        if ('${row['id']}'.startsWith('service_providers-'))
          ServiceProviderCard.fromJoin(row),
    ];
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

Future<Map<String, JoinedCategory>> _javaCategoriesById() async {
  final rows = await MarketplaceApi.categories();
  final names = <String, JoinedCategory>{};
  for (final row in rows) {
    final id = '${row['id'] ?? ''}';
    final name = '${row['name'] ?? ''}'.trim();
    if (id.isEmpty || name.isEmpty) continue;
    names[id] = JoinedCategory(name: name);
  }
  return names;
}

Future<List<ServiceRequest>> _javaInbox(String providerId) async {
  try {
    final rows = await MarketplaceApi.inbox();
    return [
      for (final row in rows)
        if (providerId.isEmpty || '${row['providerId'] ?? ''}' == providerId)
          ServiceRequest.fromJson(row),
    ];
  } on JavaApiException catch (error) {
    if (error.code == 'PROVIDER_NOT_FOUND' || error.code.contains('404')) {
      return const [];
    }
    rethrow;
  }
}

