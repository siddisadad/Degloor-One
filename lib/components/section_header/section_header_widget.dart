import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'section_header_model.dart';
export 'section_header_model.dart';

class SectionHeaderWidget extends StatefulWidget {
  const SectionHeaderWidget({
    super.key,
    String? step,
    String? title,
  })  : step = step ?? '1',
        title = title ?? 'Business Identity';

  final String step;
  final String title;

  @override
  State<SectionHeaderWidget> createState() => _SectionHeaderWidgetState();
}

class _SectionHeaderWidgetState extends State<SectionHeaderWidget> {
  late SectionHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SectionHeaderModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary10,
                borderRadius: BorderRadius.circular(9999.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                child: Text(
                  valueOrDefault<String>(
                    'STEP ${widget.step}',
                    'STEP 1',
                  ),
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelSmall
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        lineHeight: 1.2,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
            ),
          ].divide(const SizedBox(width: 8.0)),
        ),
        Text(
          valueOrDefault<String>(
            widget.title,
            'Business Identity',
          ),
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                lineHeight: 1.3,
              ),
        ),
      ].divide(const SizedBox(height: 4.0)),
    );
  }
}
