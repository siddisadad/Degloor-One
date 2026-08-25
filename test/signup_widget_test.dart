import 'package:degloor_one/features/auth/signup_model.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signup validates email and matching passwords', (tester) async {
    late SignUpModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => SignUpModel());
        return const SizedBox.shrink();
      }),
    ));

    expect(model.validate(), contains('email and password'));

    model.emailModel.inputTextController =
        TextEditingController(text: 'not-an-email');
    model.passwordModel.inputTextController =
        TextEditingController(text: 'secret1');
    model.confirmModel.inputTextController =
        TextEditingController(text: 'secret1');
    expect(model.validate(), contains('valid email'));

    model.emailModel.inputTextController =
        TextEditingController(text: 'new@degloor.local');
    model.confirmModel.inputTextController =
        TextEditingController(text: 'other');
    expect(model.validate(), contains('do not match'));

    model.passwordModel.inputTextController =
        TextEditingController(text: 'short');
    model.confirmModel.inputTextController =
        TextEditingController(text: 'short');
    expect(model.validate(), contains('at least 6 characters'));

    model.passwordModel.inputTextController =
        TextEditingController(text: 'secret1');
    model.confirmModel.inputTextController =
        TextEditingController(text: 'secret1');
    expect(model.validate(), isNull);
  });

  testWidgets('customer signup continues through initialize', (tester) async {
    late SignUpModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => SignUpModel());
        return const SizedBox.shrink();
      }),
    ));
    expect(await model.routeAfterAuth(bypassAuth: false), '_initialize');
    expect(await model.routeAfterAuth(bypassAuth: true), '_initialize');
  });

  testWidgets('business signup continues to shop registration', (tester) async {
    late SignUpModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => SignUpModel());
        return const SizedBox.shrink();
      }),
    ));
    model.isBusinessOwner = true;
    expect(
      await model.routeAfterAuth(bypassAuth: true),
      'BusinessRegistration',
    );
  });
}
