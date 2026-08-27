import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class CartConflictDialog extends StatelessWidget {
  const CartConflictDialog({
    super.key,
    required this.shopName,
  });

  final String shopName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start new cart?'),
      content: Text(
        'Your cart has items from another shop. Would you like to clear it and start a new order from $shopName?',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: DegloorTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
            ),
          ),
          child: const Text('Clear & Start New'),
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context, String shopName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => CartConflictDialog(shopName: shopName),
        ) ??
        false;
  }
}
