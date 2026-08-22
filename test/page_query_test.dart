import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';

void main() {
  test('page query advances by limit', () {
    const first = PageQuery(limit: 20);
    expect(first.from, 0);
    expect(first.to, 19);
    final next = first.next();
    expect(next.offset, 20);
    expect(next.to, 39);
  });

  test('showcase catalog applies offset pagination', () {
    ShowcaseCatalog.reset();
    final q = ShowcaseQuery()
      ..order('created_at', ascending: false)
      ..range(0, 1);
    final page = ShowcaseCatalog.query('orders', q);
    expect(page.length, 2);
  });
}
