import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/features/businesses/edit_business_profile_model.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ShowcaseCatalog.reset();
    currentUser = null;
  });

  testWidgets('edit profile photo upload stays on the model', (tester) async {
    installGuestSession();
    late EditBusinessProfileModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => EditBusinessProfileModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.uploadPhotoBytes(
      userId: currentUserUid,
      businessId: ShowcaseCatalog.bizPatil,
      bytes: const [1, 2, 3],
    );
    expect(model.imageUrl, isNotEmpty);
    expect(model.imageUrl, contains('unsplash'));
    expect(model.imageUrl, contains(ShowcaseCatalog.bizPatil));
    expect(model.isUploading, isFalse);
  });

  testWidgets('edit profile photo upload without a session asks to log in',
      (tester) async {
    late EditBusinessProfileModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => EditBusinessProfileModel());
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

  testWidgets('edit profile save writes the photo on the model', (tester) async {
    installGuestSession();
    late EditBusinessProfileModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => EditBusinessProfileModel());
        return const SizedBox.shrink();
      }),
    ));

    model.textFieldModel1.inputTextController =
        TextEditingController(text: 'Patil Kirana Plus');
    await model.uploadPhotoBytes(
      userId: currentUserUid,
      businessId: ShowcaseCatalog.bizPatil,
      bytes: const [7, 8, 9],
    );
    await model.save(
      userId: currentUserUid,
      businessId: ShowcaseCatalog.bizPatil,
    );

    final shop =
        await BusinessService.instance.requireOwned(GuestAuthUser.guestUid);
    expect(shop.name, 'Patil Kirana Plus');
    expect(shop.imageUrl, model.imageUrl);
  });

  testWidgets('edit profile save without a session asks to log in',
      (tester) async {
    late EditBusinessProfileModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => EditBusinessProfileModel());
        return const SizedBox.shrink();
      }),
    ));

    expect(
      () => model.save(userId: '', businessId: ShowcaseCatalog.bizPatil),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Please login to update the shop'),
      )),
    );
  });
}
