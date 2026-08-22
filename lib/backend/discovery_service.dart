import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';

class DiscoveryService {
  DiscoveryService({DiscoveryRepository? repository})
      : _repository = repository ?? DiscoveryRepository();

  final DiscoveryRepository _repository;

  static final instance = DiscoveryService();

  Future<PageResult<BusinessesRow>> search(DiscoverySearch query) async {
    final rows = await _repository.search(query);
    return PageResult(items: rows, hasMore: rows.length >= query.page.limit);
  }

  Future<List<BusinessCategoriesRow>> categories() => _repository.categories();

  Future<List<UsersRow>> profile(String userId) {
    if (userId.isEmpty) return Future.value(const []);
    return _repository.usersByIds([userId]);
  }

  Future<List<UsersRow>> usersByIds(List<String> ids) =>
      _repository.usersByIds(ids);
}
