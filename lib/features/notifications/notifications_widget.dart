import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = currentUserUid;
      if (user == '') return;

      _notifications = await NotificationsTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', user)
            .order('created_at', ascending: false),
      );
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await NotificationsTable().update(
        data: {'is_read': true},
        matchingRows: (q) => q.eq('id', id),
      );
      await _loadNotifications();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = currentUserUid;
      if (user == '') return;

      await NotificationsTable().update(
        data: {'is_read': true},
        matchingRows: (q) => q.eq('user_id', user).eq('is_read', false),
      );
      await _loadNotifications();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  @override
  void dispose() {
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Notifications',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          actions: [
            if (_notifications.any((n) => !n.isRead))
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                child: TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Mark all as read',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
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
                              padding: EdgeInsets.all(16),
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
                                  SizedBox(height: 8),
                                  Text(
                                    notification.message,
                                    style: FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                  if (!notification.isRead)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
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
