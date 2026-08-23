import 'package:degloor_one/shared/rpc_row.dart';

/// Tokenized marketplace query. Every token must appear in the haystack.
class SearchQuery {
  const SearchQuery(this.tokens);

  final List<String> tokens;

  static final _split = RegExp(r'\s+');

  static SearchQuery parse(String? raw) {
    final cleaned = sanitizeIlike(raw ?? '');
    if (cleaned.isEmpty) return const SearchQuery([]);
    return SearchQuery(
      cleaned
          .toLowerCase()
          .split(_split)
          .where((token) => token.isNotEmpty)
          .toList(growable: false),
    );
  }

  bool get isEmpty => tokens.isEmpty;

  String get raw => tokens.join(' ');

  bool matches(Iterable<String?> fields) {
    if (isEmpty) return true;
    final hay = fields
        .whereType<String>()
        .map((field) => field.toLowerCase())
        .join(' ');
    return tokens.every(hay.contains);
  }
}
