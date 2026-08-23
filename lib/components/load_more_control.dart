import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

/// Footer control for paged lists (orders, inbox).
class LoadMoreControl extends StatelessWidget {
  const LoadMoreControl({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      child: TextButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DegloorTheme.primary,
                ),
              )
            : Text(
                'Load more',
                style: DegloorTheme.titleMedium.copyWith(
                  color: DegloorTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
