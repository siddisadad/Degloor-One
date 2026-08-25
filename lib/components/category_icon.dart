import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.iconName,
    this.size,
    this.color,
  });

  final String? iconName;
  final double? size;
  final Color? color;

  static const Map<String, IconData> iconMap = {
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

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconMap[iconName] ?? Icons.category_rounded,
      size: size,
      color: color,
    );
  }
}
