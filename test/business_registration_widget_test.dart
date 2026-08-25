import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/business_service.dart';
import 'package:degloor_one/features/businesses/business_registration_model.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ShowcaseCatalog.reset();
    currentUser = null;
  });

  testWidgets('registration submit creates a shop and opens the dashboard',
      (tester) async {
    installGuestSession();
    late BusinessRegistrationModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => BusinessRegistrationModel());
        return const SizedBox.shrink();
      }),
    ));

    model.textFieldModel1.inputTextController =
        TextEditingController(text: 'Siddi Kirana');
    model.textFieldModel2.inputTextController =
        TextEditingController(text: 'Sadad Siddi');
    model.textFieldModel4.inputTextController =
        TextEditingController(text: '9876543210');
    model.dropdownValue = ShowcaseCatalog.catGrocery;

    expect(await model.submit(userId: currentUserUid), 'BusinessDashboard');
    expect(await getCurrentUserRole(), UserRole.businessOwner.value);

    final shops =
        await BusinessService.instance.ownedBy(GuestAuthUser.guestUid);
    expect(shops.map((shop) => shop.name), contains('Siddi Kirana'));
  });

  testWidgets('registration loads shop categories on the model',
      (tester) async {
    installGuestSession();
    late BusinessRegistrationModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => BusinessRegistrationModel());
        return const SizedBox.shrink();
      }),
    ));

    await model.loadCategories();
    expect(model.categories, isNotEmpty);
    expect(model.categories.map((row) => row.id),
        contains(ShowcaseCatalog.catGrocery));
    expect(model.dropdownValue, model.categories.first.id);
    expect(model.categoriesLoading, isFalse);
    expect(model.dropdownValueController?.value, model.dropdownValue);
  });

  testWidgets('registration photos upload before submit', (tester) async {
    installGuestSession();
    late BusinessRegistrationModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => BusinessRegistrationModel());
        return const SizedBox.shrink();
      }),
    ));

    model.textFieldModel1.inputTextController =
        TextEditingController(text: 'Siddi Kirana');
    model.textFieldModel2.inputTextController =
        TextEditingController(text: 'Sadad Siddi');
    model.textFieldModel4.inputTextController =
        TextEditingController(text: '9876543210');
    model.dropdownValue = ShowcaseCatalog.catGrocery;

    await model.uploadPhotoBytes(
      userId: currentUserUid,
      slot: RegistrationPhotoSlot.storeFront,
      bytes: const [1, 2, 3],
    );
    await model.uploadPhotoBytes(
      userId: currentUserUid,
      slot: RegistrationPhotoSlot.registrationDoc,
      bytes: const [4, 5, 6],
    );
    expect(model.storeFrontUrl, isNotEmpty);
    expect(model.registrationDocUrl, isNotEmpty);

    expect(await model.submit(userId: currentUserUid), 'BusinessDashboard');
    final shops =
        await BusinessService.instance.ownedBy(GuestAuthUser.guestUid);
    final shop = shops.singleWhere((row) => row.name == 'Siddi Kirana');
    expect(shop.imageUrl, model.storeFrontUrl);
    expect(shop.photos, containsAll([
      model.storeFrontUrl,
      model.registrationDocUrl,
    ]));
  });

  testWidgets('registration submit without a session asks the owner to log in',
      (tester) async {
    late BusinessRegistrationModel model;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        model = createModel(context, () => BusinessRegistrationModel());
        return const SizedBox.shrink();
      }),
    ));

    expect(
      () => model.submit(userId: ''),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Please login to register a business'),
      )),
    );
  });
}
