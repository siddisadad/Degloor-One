import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final theme = FlutterFlowTheme.of(context);
  return AppBar(
    backgroundColor: theme.primaryBackground,
    automaticallyImplyLeading: false,
    leading: showBack
        ? FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 8,
            borderWidth: 1,
            buttonSize: 40,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.primaryText,
              size: 22,
            ),
            onPressed: () => degloorNavigateBack(context),
          )
        : null,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.headlineMedium.override(
        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
        color: theme.primaryText,
        fontSize: 22,
      ),
    ),
    actions: actions,
    centerTitle: false,
    elevation: 0,
  );
}
