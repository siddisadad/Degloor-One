import 'package:flutter/material.dart';
import 'package:degloor_one/auth/password_recovery.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/backend/supabase/database/database.dart';

import 'package:degloor_one/core/error_handler.dart';

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
      if (PasswordRecovery.pending.value) {
        context.goNamed('ResetPassword');
        return;
      }

      if (!loggedIn) {
        context.goNamed('Authentication');
        return;
      }

      // Always fetch latest role from DB to handle role updates (e.g. after registration)
      // Added timeout to prevent hanging on poor connection
      final String? role = await getCurrentUserRole().timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (role == 'business_owner') {
        final businesses = await BusinessesTable().querySingleRow(
          queryFn: (q) => q.eq('owner_id', currentUserUid),
        ).timeout(const Duration(seconds: 10));
        if (!mounted) return;

        if (businesses.isEmpty) {
          context.goNamed('BusinessRegistration');
        } else {
          context.goNamed('BusinessDashboard');
        }
      } else if (role == 'admin') {
        context.goNamed('AdminControlPanel');
      } else {
        context.goNamed('CustomerHome');
      }
    } catch (e) {
      AppLogger.error('Redirection error', e);
      if (mounted) {
        setState(() => _errorMessage = 'Failed to load user profile. Please check your connection.');
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
