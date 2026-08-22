import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/features/delivery/delivery_dashboard_widget.dart';
import 'package:degloor_one/features/services/manage_service_requests_widget.dart';
import 'package:degloor_one/features/services/service_provider_profile_widget.dart';
import 'package:degloor_one/features/services/service_provider_registration_widget.dart';
import 'package:degloor_one/features/services/services_widget.dart';
import 'package:degloor_one/flutter_flow/nav/nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoRouter router;

  setUp(() {
    router = createRouter(AppStateNotifier.instance);
  });

  test('service and delivery pages are registered named routes', () {
    expect(router.namedLocation(ServicesWidget.routeName), '/services');
    expect(
      router.namedLocation(ServiceProviderProfileWidget.routeName),
      '/serviceProviderProfile',
    );
    expect(
      router.namedLocation(ServiceProviderRegistrationWidget.routeName),
      '/serviceProviderRegistration',
    );
    expect(
      router.namedLocation(ManageServiceRequestsWidget.routeName),
      '/manageServiceRequests',
    );
    expect(
      router.namedLocation(DeliveryDashboardWidget.routeName),
      '/deliveryDashboard',
    );
  });
}
