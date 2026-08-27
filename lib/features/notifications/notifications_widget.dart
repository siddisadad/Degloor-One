import 'dart:async';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/load_more_control.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/shared/app_notification.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
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
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _loadToken = 0;
  static const _pageSize = 20;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;

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
        page: PageQuery(offset: _offset),
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
        title: const Text('Clear all'),
        content: const Text('Delete every notification in this inbox?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
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
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(
          context,
          title: 'Notifications',
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
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: DegloorTheme.primary),
              )
            : _notifications.isEmpty
                ? EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: "You're all caught up",
                    description: 'Order updates and local alerts will land here.',
                    buttonText: 'Back to home',
                    onTap: () => context.goNamed('CustomerHome'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: DegloorTheme.spacingSM),
                    itemBuilder: (context, index) {
                      if (index >= _notifications.length) {
                        return LoadMoreControl(
                          loading: _loadingMore,
                          onPressed: () => _loadPage(),
                        );
                      }
                      final notification = _notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            _markAsRead(notification.id);
                          }
                          _handleNotificationTap(notification);
                        },
                      );
                    },
                  ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    final type = notification.type;
    final refId = notification.referenceId;

    if (type == 'order_status' && refId != null) {
      context.pushNamed(
        'OrderTracking',
        queryParameters: {'orderId': refId},
      );
    } else if (type == 'service_request') {
      if (notification.title.toLowerCase().contains('new')) {
        context.pushNamed('ManageServiceRequests');
      } else {
        context.pushNamed('UserServiceRequests');
      }
    } else if (type == 'new_review') {
      // Navigate to Business Dashboard (owner)
      context.pushNamed('BusinessDashboard');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final icon = _getIcon();

    return Material(
      color: unread ? DegloorTheme.accent : DegloorTheme.cardBackground,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(
              color: unread
                  ? DegloorTheme.primary.withValues(alpha: 0.25)
                  : DegloorTheme.border,
            ),
            boxShadow: DegloorTheme.softShadow,
          ),
          padding: const EdgeInsets.all(DegloorTheme.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unread ? Colors.white : DegloorTheme.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: unread ? DegloorTheme.primary : DegloorTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DegloorTheme.titleMedium.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateTimeFormat(
                              'MMM d, h:mm a', notification.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DegloorTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: DegloorTheme.bodyMedium.copyWith(
                        color: DegloorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: 8),
                  decoration: const BoxDecoration(
                    color: DegloorTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'order_status':
        return Icons.shopping_bag_rounded;
      case 'service_request':
        return Icons.handyman_rounded;
      case 'new_review':
        return Icons.star_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
