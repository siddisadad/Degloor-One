import 'package:degloor_one/backend/notification_service.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
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
import 'package:degloor_one/core/error_handler.dart';
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
      AppLogger.error('Error fetching weekly hours', e);
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
        const SnackBar(content: Text('Please sign in to write a review')),
      );
      return;
    }

    final business = await _businessFuture;
    if (business == null || !mounted) return;

    int rating = 5;
    final commentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Write a Review',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'How was your experience with ${business.name}?',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 24),
              StatefulBuilder(
                builder: (context, setInternalState) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return InkWell(
                      onTap: () {
                        setInternalState(() => rating = index + 1);
                        rating = index + 1;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 48,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Describe your experience (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              FFButtonWidget(
                onPressed: () async {
                  if (rating < 1) return;

                  await ReviewsTable().insert({
                    'user_id': currentUser,
                    'business_id': business.id,
                    'rating': rating,
                    'comment': commentController.text.trim(),
                    'created_at': DateTime.now().toIso8601String(),
                  });

                  // Log Review Submitted
                  logBusinessEvent(
                    businessId: business.id,
                    eventType: BusinessAnalyticsEvents.reviewSubmitted,
                  );

                  // Notify Owner
                  if (business.ownerId != null) {
                    await NotificationService.notifyNewReview(
                      ownerId: business.ownerId!,
                      businessName: business.name,
                      rating: rating,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your review!')),
                    );
                  }
                  safeSetState(() {
                    _model.reviewsFuture = _fetchReviews();
                  });
                },
                text: 'Submit Review',
                options: FFButtonOptions(
                  height: 50,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBusinessHoursDialog() async {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Schedule'),
        content: SizedBox(
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
                          : '${dateTimeFormat('h:mm a', row.openTime!.time)} - ${dateTimeFormat('h:mm a', row.closeTime!.time)}',
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final currentUser = currentUserUid;
    if (currentUser == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to report a listing')),
      );
      return;
    }

    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
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
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted successfully')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final dist = _model.ratingDistribution;
    final total = dist.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

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
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
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
                    const SizedBox(height: 16),
                    const Text('Connection error. Please check your internet.'),
                    const SizedBox(height: 24),
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
              children: [
                SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 260.0,
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: business.imageUrl ??
                                  'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                              height: 260.0,
                              fit: BoxFit.cover,
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
                              alignment: const AlignmentDirectional(0.0, 1.0),
                              child: Container(
                                height: 100.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      FlutterFlowTheme.of(context).fullContrast60
                                    ],
                                    stops: const [0.0, 1.0],
                                    begin: const AlignmentDirectional(0.0, -1.0),
                                    end: const AlignmentDirectional(0, 1.0),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(0.0, -1.0),
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          if (context.mounted) {
                                            context.safePop();
                                          }
                                        },
                                      ),
                                      Row(
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
                                              AppLogger.log('Favorite button pressed');
                                            },
                                          ),
                                        ].divide(const SizedBox(width: 8.0)),
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Title & Verification Row
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
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
                                  ].divide(const SizedBox(width: 8.0)),
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
                              children: [
                                Row(
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
                                  ].divide(const SizedBox(width: 4.0)),
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
                              ].divide(const SizedBox(width: 16.0)),
                            ),
                            // 3. Action Buttons Row
                            Row(
                              children: [
                                Expanded(
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
                                      label: AppLocalizations.of(context)!.call,
                                      onTap: () async {
                                        if (business.phoneNumber != null && business.phoneNumber!.trim().isNotEmpty) {
                                          final url = Uri.parse('tel:${business.phoneNumber!.trim()}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                            // Log Call Click
                                            logBusinessEvent(
                                              businessId: business.id,
                                              eventType: BusinessAnalyticsEvents.callClick,
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Phone number not available')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
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
                                    label: AppLocalizations.of(context)!.whatsApp,
                                    onTap: () async {
                                      if (business.whatsappNumber != null && business.whatsappNumber!.trim().isNotEmpty) {
                                        await WhatsAppService.launchWhatsApp(
                                          phoneNumber: business.whatsappNumber!.trim(),
                                          message:
                                              'Hello ${business.name}, I found your shop on DEGLOOR ONE app.',
                                        );
                                        // Log WhatsApp Click
                                        logBusinessEvent(
                                          businessId: business.id,
                                          eventType: BusinessAnalyticsEvents.whatsappClick,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('WhatsApp number not available')),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
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
                                      label: AppLocalizations.of(context)!.directions,
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
                              ].divide(const SizedBox(width: 16.0)),
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(
                                  'BusinessCatalogue',
                                  queryParameters: {
                                    'businessId': serializeParam(
                                      business.id,
                                      ParamType.string,
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
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      size: 20.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
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
                                  ].divide(const SizedBox(width: 16.0)),
                                ),
                              ),
                            ),
                            // 5. Location Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
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
                                  ].divide(const SizedBox(width: 8.0)),
                                ),
                              ].divide(const SizedBox(height: 8.0)),
                            ),
                            // 6. Products & Services Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
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
                                              'businessId': serializeParam(business.id, ParamType.string),
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
                              ].divide(const SizedBox(height: 8.0)),
                            ),
                            // 7. About Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
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
                              ].divide(const SizedBox(height: 8.0)),
                            ),
                            // 8. Reviews Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      text: AppLocalizations.of(context)!.writeReview,
                                      options: FFButtonOptions(
                                        width: 120,
                                        height: 36,
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        color: Colors.transparent,
                                        textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
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
                                          padding: const EdgeInsets.all(16.0),
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
                              ].divide(const SizedBox(height: 16.0)),
                            ),
                          ].divide(const SizedBox(height: 24.0)),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: Container(
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
                          child: Container(
                            height: 47.0,
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (business.isVerified ?? false) ? 'Verified Listing' : 'Listing Pending Verification',
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: (business.isVerified ?? false) ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).secondaryText,
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
                                      content: AppLocalizations.of(context)!.reportListing,
                                      variant: 'outline',
                                      size: 'small',
                                      fullWidth: false,
                                      loading: false,
                                      disabled: false,
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(width: 16.0)),
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
