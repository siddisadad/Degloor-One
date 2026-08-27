import 'dart:async';

import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/service_request.dart';
import 'package:flutter/material.dart';
import 'user_service_requests_model.dart';
export 'user_service_requests_model.dart';

class UserServiceRequestsWidget extends StatefulWidget {
  const UserServiceRequestsWidget({super.key});

  static String routeName = 'UserServiceRequests';
  static String routePath = '/myServiceRequests';

  @override
  State<UserServiceRequestsWidget> createState() =>
      _UserServiceRequestsWidgetState();
}

class _UserServiceRequestsWidgetState extends State<UserServiceRequestsWidget> {
  late UserServiceRequestsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<List<ServiceRequest>>? _requestsSub;
  List<ServiceRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserServiceRequestsModel());
    if (loggedIn) {
      _requestsSub = ServiceMarketplaceService.instance
          .watchForUser(currentUserUid)
          .listen((requests) {
        if (mounted) {
          setState(() {
            _requests = requests..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _loading = false;
          });
        }
      });
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _requestsSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'My Service Requests'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _requests.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.handyman_outlined,
                          title: 'No requests yet',
                          description:
                              'Book a local service to see your tracking here.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final req = _requests[index];
                            final providerName = req.provider?.displayName(
                                  fallback: 'Service Provider',
                                ) ??
                                'Service Provider';
                            return _buildRequestCard(req, providerName);
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequest req, String providerName) {
    final status = req.status ?? ServiceRequestStatus.pending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: req.photoUrl != null
                      ? CachedRemoteImage(url: req.photoUrl!, width: 44, height: 44)
                      : degloorImageFallback(width: 44, height: 44, icon: Icons.person_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(providerName, style: DegloorTheme.titleMedium),
                      Text(
                        req.scheduledAt != null
                            ? dateTimeFormat('MMM d, h:mm a', req.scheduledAt)
                            : 'Not scheduled',
                        style: DegloorTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _statusBadge(status),
              ],
            ),
            const Divider(height: 24),
            Text('Request Details:', style: DegloorTheme.labelSmall),
            const SizedBox(height: 4),
            Text(req.description ?? 'No description', style: DegloorTheme.bodyMedium),
            if (status == ServiceRequestStatus.accepted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => WhatsAppService.launchWhatsApp(
                        phoneNumber: '+919876543210', // Simplified for demo
                        message: 'Hello, following up on my service request.',
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Contact Provider'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DegloorTheme.success,
                        side: const BorderSide(color: DegloorTheme.success),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'declined':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
