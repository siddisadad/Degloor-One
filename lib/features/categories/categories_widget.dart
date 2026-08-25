import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/components/category_icon.dart';
import 'package:degloor_one/components/degloor_app_bar.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/modern/modern_category_item.dart';
import 'package:degloor_one/core/degloor_theme.dart';
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

  Future<List<ShopCategory>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoriesModel());
    _categoriesFuture = DiscoveryService.instance.categories();
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
              child: FutureBuilder<List<ShopCategory>>(
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: DegloorTheme.primary,
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
                        icon: CategoryIcon(iconName: category.iconName),
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
