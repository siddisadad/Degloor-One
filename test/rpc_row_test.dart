import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/rpc_row.dart';

void main() {
  test('asRpcRow accepts a map or a one-row list', () {
    expect(asRpcRow({'id': 'row-1'}), {'id': 'row-1'});
    expect(
      asRpcRow([
        {'id': 'row-2'},
      ]),
      {'id': 'row-2'},
    );
    expect(asRpcRow(null), isNull);
    expect(asRpcRow(<dynamic>[]), isNull);
    expect(asRpcRow('uuid-only'), isNull);
    expect(asRpcRow('{"ok":true,"code":null}'), {'ok': true, 'code': null});
    expect(
      asRpcRow('[{"ok":false,"code":"needs_replacement"}]'),
      {'ok': false, 'code': 'needs_replacement'},
    );
  });

  test('sanitizeIlike strips wildcard characters', () {
    expect(sanitizeIlike('  %cook_  '), 'cook');
    expect(sanitizeIlike('counter assistant'), 'counter assistant');
  });
}
