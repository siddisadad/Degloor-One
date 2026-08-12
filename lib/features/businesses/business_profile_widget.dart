import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/action_button/action_button_widget.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/review_card/review_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:degloor_one/app_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import 'package:degloor_one/backend/supabase/analytics.dart';
import 'business_profile_model.dart';
export 'business_profile_model.dart';

class BusinessProfileWidget extends StatefulWidget {
  const BusinessProfileWidget({
    super.key,
    this.businessId,
  });

  final String? businessId;

  static String routeName = 'BusinessProfile';
  static String routePath = '/businessProfile';

  @override
  State<BusinessProfileWidget> createState() => _BusinessProfileWidgetState();
}

class _BusinessProfileWidgetState extends State<BusinessProfileWidget> {
  late BusinessProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<BusinessesRow?>? _businessFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessProfileModel());
    if (widget.businessId != null) {
      final bId = widget.businessId!;
      _businessFuture = BusinessesTable()
          .querySingleRow(
            queryFn: (q) => q.eq('id', bId),
          )
          .then((rows) async {
            if (rows.isEmpty) return null;
            final business = rows.first;

            // Fetch category name
            if (business.categoryId != null) {
              final cats = await BusinessCategoriesTable().queryRows(
                queryFn: (q) => q.eq('id', business.categoryId!),
              );
              if (cats.isNotEmpty) {
                safeSetState(() {
                  _model.categoryName = cats.first.name;
                });
              }
            }

            // Fetch open status
            final isOpenCalculated = await getBusinessOpenStatus(bId);
            final isOpen = (business.isOpen ?? false) && isOpenCalculated;
            safeSetState(() {
              _model.isOpen = isOpen;
              _model.statusMessage = isOpen ? 'Open Now' : 'Closed';
            });

            // Log Profile View
            logBusinessEvent(
              businessId: bId,
              eventType: BusinessAnalyticsEvents.profileView,
            );

            return business;
          });
      _model.reviewsFuture = _fetchReviews();
      _fetchWeeklyHours(bId);
    }
  }

  Future<void> _fetchWeeklyHours(String bId) async {
    try {
      final hours = await BusinessHoursTable().queryRows(
        queryFn: (q) => q.eq('business_id', bId).order('day_of_week'),
      );
      safeSetState(() {
        _model.weeklyHours = hours;
      });
    } catch (e) {
      print('Error fetching weekly hours: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    final response = await SupaFlow.client
        .from('reviews')
        .select('*, users(full_name)')
        .eq('business_id', widget.businessId!)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> reviews = List<Map<String, dynamic>>.from(response);

    // Calculate distribution
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      final rating = (r['rating'] as num).toInt();
      if (dist.containsKey(rating)) {
        dist[rating] = dist[rating]! + 1;
      }
    }
    safeSetState(() {
      _model.ratingDistribution = dist;
    });

    return reviews;
  }

  Future<void> _showWriteReviewDialog() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to write a review')),
      );
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(hintText: 'Enter your comment'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ReviewsTable().insert({
                  'user_id': currentUser,
                  'business_id': widget.businessId,
                  'rating': rating,
                  'comment': commentController.text,
                });
                // Log Review Submitted
                logBusinessEvent(
                  businessId: widget.businessId!,
                  eventType: BusinessAnalyticsEvents.reviewSubmitted,
                );
                Navigator.pop(context);
                safeSetState(() {
                  _model.reviewsFuture = _fetchReviews();
                });
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBusinessHoursDialog() async {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weekly Schedule'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (index) {
              final row = _model.weeklyHours?.firstWhereOrNull((h) => h.dayOfWeek == index);
              final isToday = DateTime.now().weekday % 7 == index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    Text(
                      row == null || row.isClosed || row.openTime?.time == null || row.closeTime?.time == null
                          ? 'Closed'
                          : '${dateTimeFormat('h:mm a', row.openTime!.time!)} - ${dateTimeFormat('h:mm a', row.closeTime!.time!)}',
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: row == null || row.isClosed || row.openTime?.time == null || row.closeTime?.time == null ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to report a listing')),
      );
      return;
    }

    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              await ComplaintsTable().insert({
                'user_id': currentUser,
                'business_id': widget.businessId,
                'subject': subjectController.text,
                'description': descriptionController.text,
                'status': 'pending',
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report submitted successfully')),
              );
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final dist = _model.ratingDistribution;
    final total = dist.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: List.generate(5, (index) {
          final star = 5 - index;
          final count = dist[star] ?? 0;
          final percent = count / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Text('$star', style: FlutterFlowTheme.of(context).bodySmall),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: FlutterFlowTheme.of(context).alternate,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$count', style: FlutterFlowTheme.of(context).labelSmall),
              ],
            ),
          );
        }),
      ),
    );
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
        body: FutureBuilder<BusinessesRow?>(
          future: _businessFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: FlutterFlowTheme.of(context).secondaryText),
                    SizedBox(height: 16),
                    Text('Connection error. Please check your internet.'),
                    SizedBox(height: 24),
                    FFButtonWidget(
                      onPressed: () => setState(() {
                        if (widget.businessId != null) {
                          _businessFuture = BusinessesTable().querySingleRow(
                            queryFn: (q) => q.eq('id', widget.businessId!),
                          ).then((rows) => rows.isNotEmpty ? rows.first : null);
                        }
                      }),
                      text: 'Retry',
                      options: FFButtonOptions(
                        width: 150,
                        height: 44,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.inter(),
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              );
            }
            final business = snapshot.data;
            if (business == null) {
              return Center(
                child: Text(
                  'Business not found',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              );
            }
            return Stack(
              alignment: AlignmentDirectional(-1.0, -1.0),
              children: [
                SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 260.0,
                        child: Stack(
                          alignment: AlignmentDirectional(-1.0, -1.0),
                          children: [
                            CachedNetworkImage(
                              imageUrl: business.imageUrl ??
                                  'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                              height: 260.0,
                              fit: BoxFit.cover,
                              alignment: Alignment(0.0, 0.0),
                              errorWidget: (context, url, error) => Container(
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 48,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: Container(
                                height: 100.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      FlutterFlowTheme.of(context).fullContrast60
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              child: SafeArea(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      FlutterFlowIconButton(
                                        borderRadius: 9999.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context).surface80,
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          context.safePop();
                                        },
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          FlutterFlowIconButton(
                                            borderRadius: 9999.0,
                                            buttonSize: 40.0,
                                            fillColor: FlutterFlowTheme.of(context).surface80,
                                            icon: Icon(
                                              Icons.share_rounded,
                                              color: FlutterFlowTheme.of(context).primaryText,
                                              size: 24.0,
                                            ),
                                      onPressed: () async {
                                        await Share.share(
                                          'Check out ${business.name} on DEGLOOR ONE! \n${business.description ?? ''}',
                                          subject: business.name,
                                        );
                                        // Log Share Click
                                        logBusinessEvent(
                                          businessId: business.id,
                                          eventType: BusinessAnalyticsEvents.shareClick,
                                        );
                                      },
                                          ),
                                          FlutterFlowIconButton(
                                            borderRadius: 9999.0,
                                            buttonSize: 40.0,
                                            fillColor: FlutterFlowTheme.of(context).surface80,
                                            icon: Icon(
                                              Icons.favorite_border_rounded,
                                              color: FlutterFlowTheme.of(context).primaryText,
                                              size: 24.0,
                                            ),
                                            onPressed: () {
                                              print('IconButton pressed ...');
                                            },
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Title & Verification Row
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      business.name,
                                      style: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                    if (business.isVerified ?? false)
                                      Icon(
                                        Icons.verified_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 22.0,
                                      ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                                if (business.ownerName != null && business.ownerName!.isNotEmpty)
                                  Text(
                                    'Owned by ${business.ownerName}',
                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                  ),
                              ],
                            ),
                            // 2. Rating & Category Row
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: FlutterFlowTheme.of(context).onBackground,
                                      size: 18.0,
                                    ),
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _model.reviewsFuture,
                                      builder: (context, snapshot) {
                                        final reviews = snapshot.data ?? [];
                                        return Text(
                                          '${business.rating ?? 0.0} (${reviews.length} reviews)',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                              ),
                                        );
                                      },
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                                Text(
                                  '•',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        lineHeight: 1.5,
                                      ),
                                ),
                                Text(
                                  _model.categoryName ?? 'Local Business',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                            // 3. Action Buttons Row
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: wrapWithModel(
                                    model: _model.actionButtonModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ActionButtonWidget(
                                      bg: FlutterFlowTheme.of(context)
                                          .primaryContainer,
                                      borderColor: FlutterFlowTheme.of(context)
                                          .primaryContainer,
                                      color: FlutterFlowTheme.of(context)
                                          .primary,
                                      icon: Icon(
                                        Icons.call_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 24.0,
                                      ),
                                      label: 'Call',
                                      onTap: () async {
                                        if (business.phoneNumber != null) {
                                          final url = Uri.parse('tel:${business.phoneNumber}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                            // Log Call Click
                                            logBusinessEvent(
                                              businessId: business.id,
                                              eventType: BusinessAnalyticsEvents.callClick,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ActionButtonWidget(
                                    bg: const Color(0xFFE8F5E9),
                                    borderColor:
                                        FlutterFlowTheme.of(context).success20,
                                    color: FlutterFlowTheme.of(context).success,
                                    icon: Icon(
                                      Icons.chat_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24.0,
                                    ),
                                    label: 'WhatsApp',
                                    onTap: () async {
                                      if (business.whatsappNumber != null) {
                                        await WhatsAppService.launchWhatsApp(
                                          phoneNumber: business.whatsappNumber!,
                                          message:
                                              'Hello ${business.name}, I found your shop on DEGLOOR ONE app.',
                                        );
                                        // Log WhatsApp Click
                                        logBusinessEvent(
                                          businessId: business.id,
                                          eventType: BusinessAnalyticsEvents.whatsappClick,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: wrapWithModel(
                                    model: _model.actionButtonModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ActionButtonWidget(
                                      bg: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderColor: FlutterFlowTheme.of(context)
                                          .alternate,
                                      color: FlutterFlowTheme.of(context)
                                          .primary,
                                      icon: Icon(
                                        Icons.directions_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 24.0,
                                      ),
                                      label: 'Directions',
                                      onTap: () async {
                                        if (business.latitude != null && business.longitude != null) {
                                          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${business.latitude},${business.longitude}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                            // Log Directions Click
                                            logBusinessEvent(
                                              businessId: business.id,
                                              eventType: BusinessAnalyticsEvents.directionsClick,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(
                                  'BusinessCatalogue',
                                  queryParameters: {
                                    'businessId': serializeParam(
                                      business.id,
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              text: 'View Catalogue',
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                elevation: 2,
                              ),
                            ),
                            // 4. Status & Distance Card
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      size: 20.0,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _model.statusMessage ?? 'Checking...',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: (_model.isOpen ?? false)
                                                      ? FlutterFlowTheme.of(context).success
                                                      : FlutterFlowTheme.of(context).error,
                                                  fontWeight: FontWeight.w600,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          Text(
                                            (_model.isOpen ?? false) ? 'Open now' : 'Currently closed',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () => _showBusinessHoursDialog(),
                                      text: 'View Schedule',
                                      options: FFButtonOptions(
                                        width: 100,
                                        height: 32,
                                        color: Colors.transparent,
                                        textStyle: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).primary,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    Container(
                                      width: 1.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).alternate,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          getDistance(business.latitude, business.longitude),
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                        Text(
                                          'within ${FFAppState.instance.discoveryRadius.toInt()}km radius',
                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                lineHeight: 1.2,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ),
                            ),
                            // 5. Location Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      size: 20.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        business.addressText ?? 'Address not available',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            // 6. Products & Services Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Products & Services',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.shopping_bag_rounded, color: FlutterFlowTheme.of(context).primary),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Browse Catalogue', style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                              Text('View all products and prices', style: FlutterFlowTheme.of(context).labelSmall),
                                            ],
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () => context.pushNamed(
                                            'BusinessCatalogue',
                                            queryParameters: {
                                              'businessId': serializeParam(business.id, ParamType.String),
                                            }.withoutNulls,
                                          ),
                                          text: 'View',
                                          options: FFButtonOptions(
                                            width: 80,
                                            height: 36,
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            // 7. About Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                Text(
                                  business.description ?? 'No description available for this business.',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        lineHeight: 1.5,
                                      ),
                                ),
                                if (business.isVerified ?? false)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.verified_user_rounded, color: FlutterFlowTheme.of(context).primary, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified by DEGLOOR ONE Team',
                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            // 8. Reviews Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Reviews',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await _showWriteReviewDialog();
                                      },
                                      text: 'Write Review',
                                      options: FFButtonOptions(
                                        width: 120,
                                        height: 36,
                                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        color: Colors.transparent,
                                        textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        elevation: 0,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildRatingDistribution(),
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _model.reviewsFuture,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 32.0,
                                          height: 32.0,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final reviews = snapshot.data!;
                                    if (reviews.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'No reviews yet.',
                                            style: FlutterFlowTheme.of(context).labelMedium,
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: reviews.map((review) {
                                        final user = review['users'] as Map<String, dynamic>?;
                                        final fullName = user?['full_name'] ?? 'Anonymous';
                                        final initials = fullName
                                            .split(' ')
                                            .take(2)
                                            .map((e) => e.isNotEmpty ? e[0] : '')
                                            .join()
                                            .toUpperCase();
                                        return ReviewCardWidget(
                                          comment: review['comment'] ?? '',
                                          date: dateTimeFormat(
                                            'MMM d, yyyy',
                                            DateTime.parse(review['created_at']),
                                          ),
                                          initials: initials,
                                          name: fullName,
                                          rating: review['rating'].toString(),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                      ),
                      Container(
                        height: 40.0,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Container(
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                          child: Container(
                            height: 47.0,
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Verified Listing',
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: FlutterFlowTheme.of(context).success,
                                              fontWeight: FontWeight.bold,
                                              lineHeight: 1.2,
                                            ),
                                      ),
                                      Text(
                                        'DEGLOOR ONE',
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              lineHeight: 1.2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await _showReportDialog();
                                  },
                                  child: wrapWithModel(
                                    model: _model.buttonModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ButtonWidget(
                                      icon: Icon(
                                        Icons.flag_rounded,
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        size: 24.0,
                                      ),
                                      iconPresent: true,
                                      iconEndPresent: false,
                                      content: 'Report Listing',
                                      variant: 'outline',
                                      size: 'small',
                                      fullWidth: false,
                                      loading: false,
                                      disabled: false,
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
