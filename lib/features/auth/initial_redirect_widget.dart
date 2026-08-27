import 'package:flutter/material.dart';
import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/features/auth/start_route.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';

export 'start_route.dart';

class InitialRedirectWidget extends StatefulWidget {
  const InitialRedirectWidget({super.key});

  static String routeName = 'InitialRedirect';
  static String routePath = '/initialRedirect';

  @override
  State<InitialRedirectWidget> createState() => _InitialRedirectWidgetState();
}

class _InitialRedirectWidgetState extends State<InitialRedirectWidget> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  void _startInitialization() {
    setState(() => _errorMessage = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleRedirect();
      }
    });
  }

  Future<void> _handleRedirect() async {
    try {
      final role = loggedIn
          ? await getCurrentUserRole().timeout(const Duration(seconds: 10))
          : null;
      if (!mounted) return;

      final route = await resolveStartRoute(
        passwordRecoveryPending: PasswordRecovery.pending.value,
        loggedIn: loggedIn,
        bypassAuth: kBypassAuth,
        role: role,
        userId: currentUserUid,
        hasOwnedShop: (id) async {
          final shops = await DiscoveryService.instance
              .ownedBy(id)
              .timeout(const Duration(seconds: 10));
          return shops.isNotEmpty;
        },
        hasProviderProfile: (id) async {
          final profile = await ServiceMarketplaceService.instance
              .forUser(id)
              .timeout(const Duration(seconds: 10));
          return profile != null;
        },
      );
      if (!mounted) return;
      context.goNamed(route);
    } catch (e) {
      AppLogger.error('Redirection error', e);
      if (mounted) {
        setState(() => _errorMessage =
            'Failed to load user profile. Please check your connection.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: FlutterFlowTheme.of(context).error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _startInitialization,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
