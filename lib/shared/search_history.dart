import 'package:degloor_one/shared/search_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recent master-search queries. Fail-soft when prefs are not ready (tests).
class SearchHistory {
  static const key = 'ff_master_search_history';
  static const maxItems = 8;

  static Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  static Future<List<String>> remember(String term) async {
    final cleaned = SearchQuery.parse(term).raw;
    if (cleaned.isEmpty) return load();
    try {
      final prefs = await SharedPreferences.getInstance();
      final next = [
        cleaned,
        ...?prefs.getStringList(key)?.where((item) => item != cleaned),
      ].take(maxItems).toList();
      await prefs.setStringList(key, next);
      return next;
    } catch (_) {
      return [cleaned];
    }
  }

  static Future<List<String>> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
    return const [];
  }
}
