import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/features/businesses/business_dashboard_widget.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/data/datasources/bind_discovery_service.dart';
import 'package:degloor_one/data/datasources/bind_order_service.dart';
import 'package:degloor_one/data/datasources/bind_shop_service.dart';

void main() {
  setUpAll(() {
    bindDiscoveryService();
    bindOrderService();
    bindShopService();
  });

  setUp(ShowcaseCatalog.reset);

  testWidgets('Dashboard shows shop name and verification badge', (tester) async {
    installGuestSession(); 
    
    await tester.pumpWidget(const MaterialApp(home: BusinessDashboardWidget()));
    await tester.pumpAndSettle();

    expect(find.text('Patil Kirana Store'), findsOneWidget);
    expect(find.text('Verified Shop'), findsOneWidget);
  });

  testWidgets('Dashboard shows action grid', (tester) async {
    installGuestSession();
    
    await tester.pumpWidget(const MaterialApp(home: BusinessDashboardWidget()));
    await tester.pumpAndSettle();

    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Hours'), findsOneWidget);
  });
}
