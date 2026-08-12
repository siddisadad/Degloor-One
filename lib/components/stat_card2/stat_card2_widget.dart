import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stat_card2_model.dart';
export 'stat_card2_model.dart';

class StatCard2Widget extends StatefulWidget {
  const StatCard2Widget({
    super.key,
    String? label,
    String? trend,
    String? value,
    bool? isPositive,
  })  : label = label ?? 'Pending Claims',
        trend = trend ?? '+3',
        value = value ?? '12',
        isPositive = isPositive ?? false;

  final String label;
  final String trend;
  final String value;
  final bool isPositive;

  @override
  State<StatCard2Widget> createState() => _StatCard2WidgetState();
}

class _StatCard2WidgetState extends State<StatCard2Widget> {
  late StatCard2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatCard2Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueOrDefault<String>(
                widget.label,
                'Pending Claims',
              ),
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).labelMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    lineHeight: 1.4,
                  ),
            ),
            Row(
              children: [
                Text(
                  valueOrDefault<String>(
                    widget.value,
                    '12',
                  ),
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                        lineHeight: 1.3,
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: valueOrDefault<Color>(
                      valueOrDefault<bool>(
                        widget.isPositive,
                        false,
                      )
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      const Color(0xFFFFEBEE),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget.trend,
                        '+3',
                      ),
                      style:
                          FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color: valueOrDefault<Color>(
                                  valueOrDefault<bool>(
                                    widget.isPositive,
                                    false,
                                  )
                                      ? FlutterFlowTheme.of(context).success
                                      : FlutterFlowTheme.of(context).error,
                                  FlutterFlowTheme.of(context).error,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                                lineHeight: 1.2,
                              ),
                    ),
                  ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ].divide(const SizedBox(height: 4.0)),
        ),
      ),
    );
  }
}
