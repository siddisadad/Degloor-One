import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/search_query.dart';

void main() {
  test('parse drops ILIKE wildcards and splits tokens', () {
    final query = SearchQuery.parse('  Fresh% Milk_ ');
    expect(query.tokens, ['fresh', 'milk']);
    expect(query.raw, 'fresh milk');
    expect(SearchQuery.parse('').isEmpty, isTrue);
    expect(SearchQuery.parse('***').isEmpty, isTrue);
  });

  test('matches requires every token in the haystack', () {
    const fields = ['Patil Kirana Store', 'Fresh Milk (1L)', 'Grocery'];
    expect(SearchQuery.parse('milk').matches(fields), isTrue);
    expect(SearchQuery.parse('patil milk').matches(fields), isTrue);
    expect(SearchQuery.parse('thali').matches(fields), isFalse);
  });
}
