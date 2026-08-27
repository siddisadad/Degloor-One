import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_tab_model.dart';
export 'auth_tab_model.dart';

class AuthTabWidget extends StatefulWidget {
  const AuthTabWidget({
    super.key,
    String? active,
    String? label,
  })  : active = active ?? 'true',
        label = label ?? 'Customer';

  final String active;
  final String label;

  @override
  State<AuthTabWidget> createState() => _AuthTabWidgetState();
}

class _AuthTabWidgetState extends State<AuthTabWidget> {
  late AuthTabModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthTabModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
        child: Align(
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Text(
            valueOrDefault<String>(
              widget.label,
              'Customer',
            ),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<String>(
                              widget.active,
                              'true',
                            ) ==
                            'false'
                        ? FlutterFlowTheme.of(context).secondaryText
                        : FlutterFlowTheme.of(context).primary,
                    FlutterFlowTheme.of(context).primary,
                  ),
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelLarge.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.4,
                ),
          ),
        ),
      ),
    );
  }
}
