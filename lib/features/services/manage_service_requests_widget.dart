import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/shared/service_provider_profile.dart';
import 'package:degloor_one/shared/service_request.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'dart:async';
import 'package:degloor_one/features/services/manage_service_requests_model.dart';
export 'package:degloor_one/features/services/manage_service_requests_model.dart';

class ManageServiceRequestsWidget extends StatefulWidget {
  const ManageServiceRequestsWidget({super.key});

  static String routeName = 'ManageServiceRequests';
  static String routePath = '/manageServiceRequests';

  @override
  State<ManageServiceRequestsWidget> createState() =>
      _ManageServiceRequestsWidgetState();
}

class _ManageServiceRequestsWidgetState
    extends State<ManageServiceRequestsWidget> {
  late ManageServiceRequestsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ServiceProviderProfile? _currentProvider;
  StreamSubscription<List<ServiceRequest>>? _requestsSubscription;
  List<ServiceRequest> _requests = [];
  final Map<String, String> _customerNames = {};
  final Map<String, String> _customerPhones = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageServiceRequestsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final user = currentUserUid;
    if (user == '') return;

    try {
      // 1. Get the provider profile for this user
      final provider = await ServiceMarketplaceService.instance.forUser(user);

      if (provider != null) {
        _currentProvider = provider;
        _listenToRequests();
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      AppLogger.error('Error initializing service requests', e);
      setState(() => _loading = false);
    }
  }

  void _listenToRequests() {
    if (_currentProvider == null) return;

    _requestsSubscription?.cancel();
    _requestsSubscription = ServiceMarketplaceService.instance
        .watchForProvider(_currentProvider!.id)
        .listen((requests) async {
      final sortedRequests = requests.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (final request in sortedRequests) {
        final id = request.userId;
        if (id == null || id.isEmpty) continue;
        final name = request.user?.fullName?.trim();
        if (name != null && name.isNotEmpty) {
          _customerNames[id] = name;
        }
        final phone = request.user?.phoneNumber?.trim();
        if (phone != null && phone.isNotEmpty) {
          _customerPhones[id] = phone;
        }
      }

      // Fetch customer names for new users
      final existingUserIds = _customerNames.keys.toSet();
      final newUserIds = sortedRequests
          .map((r) => r.userId)
          .where((id) =>
              id != null && id.length > 10 && !existingUserIds.contains(id))
          .cast<String>()
          .toSet()
          .toList();

      if (newUserIds.isNotEmpty) {
        try {
          final users = await DiscoveryService.instance.usersByIds(newUserIds);
          for (var user in users) {
            _customerNames[user.id] = user.fullName ?? 'Unknown Customer';
            if (user.phoneNumber != null) {
              _customerPhones[user.id] = user.phoneNumber!;
            }
          }
        } catch (e) {
          AppLogger.error('Error fetching customer names', e);
        }
      }

      if (mounted) {
        setState(() {
          _requests = sortedRequests;
          _loading = false;
        });
      }
    });
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await ServiceMarketplaceService.instance.updateStatus(
        requestId: requestId,
        nextStatus: newStatus,
        actorUserId: currentUserUid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLogger.userFacingMessage(
                e,
                fallback: 'Unable to update the request. Please try again.',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _requestsSubscription?.cancel();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: degloorBackButton(context, color: Colors.white),
          title: Text(
            'Service Requests',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? Center(
                    child: Text(
                      'No service requests found.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _requests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      final customerName = req.user?.displayName(
                            fallback: 'Unknown Customer',
                          ) ??
                          _customerNames[req.userId] ??
                          'Loading...';
                      final actions = ServiceMarketplaceService.instance
                          .requestActions(req.status);

                      return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    customerName,
                                    style: FlutterFlowTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.inter(),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      if ((req.user?.phoneNumber ??
                                              _customerPhones[req.userId]) !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: InkWell(
                                            onTap: () async {
                                              final opened =
                                                  await WhatsAppService
                                                      .launchWhatsApp(
                                                phoneNumber:
                                                    req.user?.phoneNumber ??
                                                        _customerPhones[
                                                            req.userId]!,
                                                message: 'Hello, I am responding to your service request on DEGLOOR ONE.',
                                              );
                                              if (!opened && context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      WhatsAppService
                                                          .unableToOpenMessage,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: FlutterFlowTheme.of(context).success,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      _buildStatusBadge(
                                        req.status ??
                                            ServiceRequestStatus.pending,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Text(
                                'Job Description:',
                                style: FlutterFlowTheme.of(context).labelSmall,
                              ),
                              Text(
                                req.description ?? 'No description',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    req.scheduledAt != null
                                        ? dateTimeFormat('MMM d, h:mm a', req.scheduledAt)
                                        : 'Not scheduled',
                                    style: FlutterFlowTheme.of(context).bodySmall,
                                  ),
                                ],
                              ),
                              if (actions.canAccept)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FFButtonWidget(
                                          onPressed: () => _updateRequestStatus(
                                            req.id,
                                            ServiceRequestStatus.accepted,
                                          ),
                                          text: 'Accept',
                                          options: FFButtonOptions(
                                            height: 36,
                                            color: Colors.green,
                                            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FFButtonWidget(
                                          onPressed: () => _updateRequestStatus(
                                            req.id,
                                            ServiceRequestStatus.declined,
                                          ),
                                          text: 'Decline',
                                          options: FFButtonOptions(
                                            height: 36,
                                            color: Colors.red,
                                            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (actions.canComplete)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: FFButtonWidget(
                                    onPressed: () => _updateRequestStatus(
                                      req.id,
                                      ServiceRequestStatus.completed,
                                    ),
                                    text: 'Mark as Completed',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 36,
                                      color: FlutterFlowTheme.of(context).primary,
                                      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
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
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
