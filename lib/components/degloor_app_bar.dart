import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// True when this page is stacked on another route (not a tab root).
bool degloorCanPop(BuildContext context) {
  final navigator = Navigator.maybeOf(context);
  if (navigator != null && navigator.canPop()) {
    return true;
  }
  try {
    return context.canPop();
  } catch (_) {
    return false;
  }
}

/// Pop the current page, or open Home when this screen is a stack root.
void degloorNavigateBack(
  BuildContext context, {
  String fallbackRoute = 'CustomerHome',
}) {
  if (degloorCanPop(context)) {
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }
    try {
      context.pop();
      return;
    } catch (_) {}
  }
  try {
    context.goNamed(fallbackRoute);
  } catch (_) {
    // No GoRouter in isolated widget tests.
  }
}

/// Back control, or null on tab roots that cannot pop.
Widget? degloorBackLeading(
  BuildContext context, {
  Color? color,
  double size = 22,
  bool? show,
}) {
  if (!(show ?? degloorCanPop(context))) {
    return null;
  }
  return degloorBackButton(context, color: color, size: size);
}

/// Leading back control used by inner Degloor pages.
Widget degloorBackButton(
  BuildContext context, {
  Color? color,
  double size = 22,
}) {
  return IconButton(
    tooltip: 'Back',
    icon: Icon(
      Icons.arrow_back_rounded,
      color: color,
      size: size,
    ),
    onPressed: () => degloorNavigateBack(context),
  );
}

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
            onPressed: () => degloorNavigateBack(context),
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
