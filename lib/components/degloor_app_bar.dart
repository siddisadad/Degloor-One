import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            onPressed: () => context.safePop(),
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
