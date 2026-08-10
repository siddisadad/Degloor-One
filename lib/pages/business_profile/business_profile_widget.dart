import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/action_button/action_button_widget.dart';
import '/components/button/button_widget.dart';
import '/components/photo_item/photo_item_widget.dart';
import '/components/review_card/review_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Future<List<ProductsRow>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessProfileModel());
    if (widget.businessId != null) {
      _businessFuture = BusinessesTable()
          .querySingleRow(
            queryFn: (q) => q.eq('id', widget.businessId),
          )
          .then((rows) => rows.isNotEmpty ? rows.first : null);
      _productsFuture = ProductsTable().queryRows(
        queryFn: (q) => q.eq('business_id', widget.businessId),
      );
      _model.reviewsFuture = _fetchReviews();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    return await SupaFlow.client
        .from('reviews')
        .select('*, users(full_name)')
        .eq('business_id', widget.businessId!)
        .order('created_at', ascending: false);
  }

  Future<void> _showWriteReviewDialog() async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to write a review')),
      );
      return;
    }

    // Check for completed order
    final completedOrders = await OrdersTable().queryRows(
      queryFn: (q) => q
          .eq('user_id', currentUser)
          .eq('business_id', widget.businessId)
          .eq('status', 'delivered'),
      limit: 1,
    );

    if (completedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only review businesses you have ordered from.')),
      );
      return;
    }

    final orderId = completedOrders.first.id;

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
                  'order_id': orderId,
                  'rating': rating,
                  'comment': commentController.text,
                });
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

  Future<void> _showReportDialog() async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
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

  Future<void> _addToCart(ProductsRow product) async {
    final currentUser = currentUserUid;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to add items to cart')),
      );
      return;
    }

    try {
      // 1. Get or create cart for this business
      final carts = await CartsTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', currentUser)
            .eq('business_id', product.businessId),
      );

      String cartId;
      if (carts.isEmpty) {
        final newCart = await CartsTable().insert({
          'user_id': currentUser,
          'business_id': product.businessId,
        });
        cartId = newCart.id;
      } else {
        cartId = carts.first.id;
      }

      // 2. Check if item already in cart
      final existingItems = await CartItemsTable().queryRows(
        queryFn: (q) => q.eq('cart_id', cartId).eq('product_id', product.id),
      );

      if (existingItems.isNotEmpty) {
        // Update quantity
        await CartItemsTable().update(
          data: {'quantity': existingItems.first.quantity + 1},
          matchingRows: (q) => q.eq('id', existingItems.first.id),
        );
      } else {
        // Insert new item
        await CartItemsTable().insert({
          'cart_id': cartId,
          'product_id': product.id,
          'quantity': 1,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
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
                            queryFn: (q) => q.eq('id', widget.businessId),
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
                              imageUrl: business.imageUrl ??
                                  'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                              height: 260.0,
                              fit: BoxFit.cover,
                              alignment: Alignment(0.0, 0.0),
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
                                            onPressed: () {
                                              print('IconButton pressed ...');
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
                                    color: FlutterFlowTheme.of(context).onBackground,
                                    size: 22.0,
                                  ),
                              ].divide(SizedBox(width: 8.0)),
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
                                  'Hardware & Steel',
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
                                      bg: FlutterFlowTheme.of(context).primaryContainer,
                                      borderColor: FlutterFlowTheme.of(context).primaryContainer,
                                      color: FlutterFlowTheme.of(context).primary,
                                      icon: Icon(
                                        Icons.call_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                      label: 'Call',
                                      onTap: 'On Tap',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: wrapWithModel(
                                    model: _model.actionButtonModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ActionButtonWidget(
                                      bg: Color(0xFFE8F5E9),
                                      borderColor: FlutterFlowTheme.of(context).success20,
                                      color: FlutterFlowTheme.of(context).success,
                                      icon: Icon(
                                        Icons.chat_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                      label: 'WhatsApp',
                                      onTap: 'On Tap',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: wrapWithModel(
                                    model: _model.actionButtonModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ActionButtonWidget(
                                      bg: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderColor: FlutterFlowTheme.of(context).alternate,
                                      color: FlutterFlowTheme.of(context).primary,
                                      icon: Icon(
                                        Icons.directions_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                      label: 'Directions',
                                      onTap: 'On Tap',
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
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
                                            'Open Now',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: FlutterFlowTheme.of(context).success,
                                                  fontWeight: FontWeight.w600,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          Text(
                                            'Closes 9:00 PM',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                        ],
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
                                          '2.4 km',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                        Text(
                                          'within 10km radius',
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
                            // 5. About Section
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
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            // 6. Catalogue Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Catalogue',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    Text(
                                      'View All',
                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context).primary,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                                FutureBuilder<List<ProductsRow>>(
                                  future: _productsFuture,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Container(
                                        height: 100.0,
                                        child: Center(
                                          child: Text(
                                            'No products available',
                                            style: FlutterFlowTheme.of(context).labelMedium,
                                          ),
                                        ),
                                      );
                                    }
                                    final products = snapshot.data!;
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: products.map((product) {
                                          final isOutOfStock = product.trackInventory == true && (product.stockQuantity ?? 0) <= 0;
                                          return Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                                            child: Container(
                                              width: 140.0,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                        child: CachedNetworkImage(
                                                          imageUrl: product.imageUrl ??
                                                              'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&h=300&q=80',
                                                          width: 140.0,
                                                          height: 100.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      if (isOutOfStock)
                                                        Container(
                                                          width: 140.0,
                                                          height: 100.0,
                                                          decoration: BoxDecoration(
                                                            color: Colors.black45,
                                                            borderRadius: BorderRadius.circular(8.0),
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: FlutterFlowTheme.of(context).error,
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              child: Text(
                                                                'OUT OF STOCK',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Text(
                                                    product.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                  ),
                                                  if (product.price != null)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '₹${product.price}',
                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                font: GoogleFonts.inter(
                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                ),
                                                                color: FlutterFlowTheme.of(context).primary,
                                                              ),
                                                        ),
                                                        FlutterFlowIconButton(
                                                          borderRadius: 8.0,
                                                          buttonSize: 32.0,
                                                          fillColor: isOutOfStock ? FlutterFlowTheme.of(context).secondaryText : FlutterFlowTheme.of(context).primary,
                                                          icon: Icon(
                                                            Icons.add_rounded,
                                                            color: FlutterFlowTheme.of(context).info,
                                                            size: 16.0,
                                                          ),
                                                          onPressed: isOutOfStock ? null : () async {
                                                            await _addToCart(product);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                ].divide(SizedBox(height: 4.0)),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            // 7. Photos Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Photos',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    Text(
                                      'See All',
                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context).primary,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      wrapWithModel(
                                        model: _model.photoItemModel1,
                                        updateCallback: () => safeSetState(() {}),
                                        child: PhotoItemWidget(
                                          desc: 'https://dimg.dreamflow.cloud/v1/image/interior%20of%20hardware%20store%20shelves',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.photoItemModel2,
                                        updateCallback: () => safeSetState(() {}),
                                        child: PhotoItemWidget(
                                          desc: 'https://dimg.dreamflow.cloud/v1/image/variety%20of%20power%20tools%20on%20display',
                                        ),
                                      ),
                                      wrapWithModel(
                                        model: _model.photoItemModel3,
                                        updateCallback: () => safeSetState(() {}),
                                        child: PhotoItemWidget(
                                          desc: 'https://dimg.dreamflow.cloud/v1/image/steel%20pipes%20inventory',
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
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
                                    InkWell(
                                      onTap: () async {
                                        await _showWriteReviewDialog();
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonModel1,
                                        updateCallback: () => safeSetState(() {}),
                                        child: ButtonWidget(
                                          iconPresent: false,
                                          iconEndPresent: false,
                                          content: 'Write Review',
                                          variant: 'ghost',
                                          size: 'small',
                                          fullWidth: false,
                                          loading: false,
                                          disabled: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                        'Degloor Discovery',
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
