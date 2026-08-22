import 'dart:async';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'notifications_model.dart';
export 'notifications_model.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  late NotificationsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<NotificationsRow> _notifications = [];
  bool _isLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;
  StreamSubscription<List<NotificationsRow>>? _notificationsSubscription;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = currentUserUid;
    if (user == '') {
      setState(() => _isLoading = false);
      return;
    }

    _notificationsSubscription?.cancel();
    _notificationsSubscription = NotificationService.instance
        .watchForUser(user)
        .listen((_) {
      if (mounted) _loadPage(reset: true);
    });
    _loadPage(reset: true);
  }

  Future<void> _loadPage({bool reset = false}) async {
    final user = currentUserUid;
    if (user == '') {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (!reset && (_loadingMore || !_hasMore)) return;
    final token = reset ? ++_loadToken : _loadToken;
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = reset && _notifications.isEmpty;
      _loadingMore = !reset;
    });
    try {
      final page = await NotificationService.instance.listForUser(
        user,
        page: PageQuery(limit: _pageSize, offset: _offset),
      );
      if (!mounted || token != _loadToken) return;
      setState(() {
        if (reset) {
          _notifications = page.items;
        } else {
          _notifications.addAll(page.items);
        }
        _offset += _pageSize;
        _hasMore = page.hasMore;
        _isLoading = false;
        _loadingMore = false;
      });
    } catch (e) {
      AppLogger.error('Error loading notifications', e);
      if (mounted && token == _loadToken) {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await NotificationService.instance.markRead(
        notificationId: id,
        userId: currentUserUid,
      );
    } catch (e) {
      AppLogger.error('Error marking as read', e);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = currentUserUid;
      if (user == '') return;
      await NotificationService.instance.markAllRead(user);
    } catch (e) {
      AppLogger.error('Error marking all as read', e);
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = currentUserUid;
        if (user == '') return;

        await NotificationService.instance.clearAll(user);
        if (mounted) _loadPage(reset: true);
      } catch (e) {
        AppLogger.error('Error clearing notifications', e);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _notificationsSubscription?.cancel();
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 8.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 22.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Notifications',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          actions: [
            if (_notifications.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (value) {
                  if (value == 'read') _markAllAsRead();
                  if (value == 'clear') _clearAll();
                },
                itemBuilder: (context) => [
                  if (_notifications.any((n) => !n.isRead))
                    const PopupMenuItem(
                      value: 'read',
                      child: Text('Mark all as read'),
                    ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear all'),
                  ),
                ],
              ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : _notifications.isEmpty
                ? EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: "You're all caught up",
                    description: 'Order updates and local alerts will land here.',
                    buttonText: 'Back to home',
                    onTap: () => context.goNamed('CustomerHome'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _notifications.length) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: TextButton(
                            onPressed: _loadingMore
                                ? null
                                : () => _loadPage(),
                            child: _loadingMore
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Load more'),
                          ),
                        );
                      }
                      final notification = _notifications[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                        child: InkWell(
                          onTap: () {
                            if (!notification.isRead) {
                              _markAsRead(notification.id);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? FlutterFlowTheme.of(context).secondaryBackground
                                  : FlutterFlowTheme.of(context).primaryBackground.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: notification.isRead
                                    ? FlutterFlowTheme.of(context).alternate
                                    : FlutterFlowTheme.of(context).primary,
                                width: notification.isRead ? 1 : 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: FlutterFlowTheme.of(context).titleSmall.override(
                                                font: GoogleFonts.inter(),
                                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        dateTimeFormat('MMM d, h:mm a', notification.createdAt),
                                        style: FlutterFlowTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    notification.message,
                                    style: FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                  if (!notification.isRead)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Tap to mark as read',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
