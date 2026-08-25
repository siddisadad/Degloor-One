import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/features/catalogue/manage_catalogue_model.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ShowcaseCatalog.reset();
    currentUser = null;
  });

  testWidgets('catalogue photo upload stays on the model', (tester) async {
    installGuestSession();
    late ManageCatalogueModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => ManageCatalogueModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.uploadPhotoBytes(
      userId: currentUserUid,
      businessId: ShowcaseCatalog.bizPatil,
      bytes: const [1, 2, 3],
    );
    expect(model.uploadedImageUrl, isNotEmpty);
    expect(model.uploadedImageUrl, contains('unsplash'));
    expect(model.uploadedImageUrl, contains('products'));
    expect(model.uploadedImageUrl, contains(ShowcaseCatalog.bizPatil));
    expect(model.isUploading, isFalse);
  });

  testWidgets('catalogue photo upload without a session asks to log in',
      (tester) async {
    late ManageCatalogueModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => ManageCatalogueModel());
        return const SizedBox.shrink();
      }),
    ));

    expect(
      () => model.uploadPhotoBytes(
        userId: '',
        businessId: ShowcaseCatalog.bizPatil,
        bytes: const [1, 2, 3],
      ),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Please login to update the shop'),
      )),
    );
  });

  testWidgets('catalogue photo upload without a shop asks to choose one',
      (tester) async {
    installGuestSession();
    late ManageCatalogueModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => ManageCatalogueModel());
        return const SizedBox.shrink();
      }),
    ));

    expect(
      () => model.uploadPhotoBytes(
        userId: currentUserUid,
        businessId: '',
        bytes: const [1, 2, 3],
      ),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Please choose a shop'),
      )),
    );
  });
}
