import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Shared app bar for inner Degloor pages.
PreferredSizeWidget degloorAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: DegloorTheme.cardBackground,
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            tooltip: 'Back',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: DegloorTheme.textPrimary,
              size: 22,
            ),
            onPressed: () => context.safePop(),
          )
        : null,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DegloorTheme.headingMedium,
    ),
    actions: actions,
    centerTitle: false,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  );
}
