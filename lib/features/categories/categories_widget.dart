import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/modern/modern_category_item.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'categories_model.dart';
export 'categories_model.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  static String routeName = 'Categories';
  static String routePath = '/categories';

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late CategoriesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<BusinessCategoriesRow>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoriesModel());
    _categoriesFuture = DiscoveryService.instance.categories();
  }

  Widget getIconFromData(String? iconName) {
    final iconMap = {
      'shopping_basket_rounded': Icons.shopping_basket_rounded,
      'restaurant_rounded': Icons.restaurant_rounded,
      'construction_rounded': Icons.construction_rounded,
      'bolt_rounded': Icons.bolt_rounded,
      'medical_services_rounded': Icons.medical_services_rounded,
      'directions_car_rounded': Icons.directions_car_rounded,
      'checkroom_rounded': Icons.checkroom_rounded,
      'content_cut_rounded': Icons.content_cut_rounded,
      'home_repair_service_rounded': Icons.home_repair_service_rounded,
      'local_pharmacy_rounded': Icons.local_pharmacy_rounded,
      'electrical_services_rounded': Icons.electrical_services_rounded,
      'agriculture_rounded': Icons.agriculture_rounded,
      'bakery_dining_rounded': Icons.bakery_dining_rounded,
      'edit_note_rounded': Icons.edit_note_rounded,
      'phonelink_setup_rounded': Icons.phonelink_setup_rounded,
      'fitness_center_rounded': Icons.fitness_center_rounded,
      'coffee_rounded': Icons.coffee_rounded,
    };

    return Icon(iconMap[iconName] ?? Icons.category_rounded);
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
        backgroundColor: DegloorTheme.background,
        appBar: degloorAppBar(context, title: 'All Categories'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: FutureBuilder<List<BusinessCategoriesRow>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const EmptyStateView(
                      icon: Icons.category_outlined,
                      title: 'Unable to load categories',
                      description: 'Please try again in a moment.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    );
                  }
                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.category_outlined,
                      title: 'No categories yet',
                      description: 'Degloor shop categories will show up here.',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(DegloorTheme.spacingLG),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 24.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ModernCategoryItem(
                        label: category.name,
                        icon: getIconFromData(category.iconName),
                        onTap: () => context.pushNamed(
                          'SearchResults',
                          queryParameters: {'categoryId': category.id},
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
