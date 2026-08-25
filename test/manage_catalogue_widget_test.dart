import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/features/catalogue/manage_catalogue_model.dart';
import 'package:degloor_one/features/catalogue/manage_catalogue_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  testWidgets('catalogue photo tile uses the shared remote image chrome',
      (tester) async {
    installGuestSession();
    await tester.pumpWidget(
      const MaterialApp(home: ManageCatalogueWidget()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('catalogue-product-photo')), findsOneWidget);
    expect(find.byIcon(Icons.add_a_photo_rounded), findsOneWidget);
    expect(find.byType(CachedRemoteImage), findsNothing);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('catalogue-product-photo'))),
      matchesSemantics(isButton: true, label: 'Product photo', hasTapAction: true),
    );
  });
}
