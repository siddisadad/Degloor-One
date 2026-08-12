import 'package:flutter/material.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/backend/supabase/database/database.dart';

class InitialRedirectWidget extends StatefulWidget {
  const InitialRedirectWidget({super.key});

  static String routeName = 'InitialRedirect';
  static String routePath = '/initialRedirect';

  @override
  State<InitialRedirectWidget> createState() => _InitialRedirectWidgetState();
}

class _InitialRedirectWidgetState extends State<InitialRedirectWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationService.updateCurrentLocation(context);
      if (mounted) {
        _handleRedirect();
      }
    });
  }

  Future<void> _handleRedirect() async {
    if (!loggedIn) {
      context.goNamed('Authentication');
      return;
    }

    // Always fetch latest role from DB to handle role updates (e.g. after registration)
    String? role = await getCurrentUserRole();
    if (!mounted) return;

    if (role == 'business_owner') {
      try {
        final businesses = await BusinessesTable().querySingleRow(
          queryFn: (q) => q.eq('owner_id', currentUserUid),
        );
        if (!mounted) return;

        if (businesses.isEmpty) {
          context.goNamed('BusinessRegistration');
        } else {
          context.goNamed('BusinessDashboard');
        }
      } catch (e) {
        print('Error checking business status: $e');
        // Fallback to dashboard if query fails, or stay on loading
        if (mounted) context.goNamed('BusinessDashboard');
      }
    } else if (role == 'admin') {
      context.goNamed('AdminControlPanel');
    } else {
      context.goNamed('CustomerHome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
