import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'completeness_card_model.dart';
export 'completeness_card_model.dart';

class CompletenessCardWidget extends StatefulWidget {
  const CompletenessCardWidget({
    super.key,
    String? hint,
    String? percent,
    double? progressVal,
  })  : hint = hint ?? 'Add business photos to reach 100%',
        percent = percent ?? '85',
        progressVal = progressVal ?? 0.85;

  final String hint;
  final String percent;
  final double progressVal;

  @override
  State<CompletenessCardWidget> createState() => _CompletenessCardWidgetState();
}

class _CompletenessCardWidgetState extends State<CompletenessCardWidget> {
  late CompletenessCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompletenessCardModel());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completeness',
                      style: FlutterFlowTheme.of(context)
                          .titleMedium
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),
                    Text(
                      'Complete these to get verified',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                            lineHeight: 1.5,
                          ),
                    ),
                  ].divide(const SizedBox(height: 4.0)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(9999.0),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                    child: Text(
                      valueOrDefault<String>(
                        '${widget.percent}%',
                        '85%',
                      ),
                      style:
                          FlutterFlowTheme.of(context).labelLarge.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .fontStyle,
                                ),
                                color: const Color(0xFF2E7D32),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                    ),
                  ),
                ),
              ],
            ),
            LinearPercentIndicator(
              percent: valueOrDefault<double>(
                widget.progressVal,
                0.85,
              ),
              lineHeight: 8.0,
              animation: true,
              animateFromLastPercent: true,
              progressColor: FlutterFlowTheme.of(context).success,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              barRadius: const Radius.circular(4.0),
              padding: EdgeInsets.zero,
            ),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: FlutterFlowTheme.of(context).accent3,
                  size: 14.0,
                ),
                Expanded(
                  child: Text(
                    valueOrDefault<String>(
                      widget.hint,
                      'Add business photos to reach 100%',
                    ),
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodySmall.fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .bodySmall.fontStyle,
                          lineHeight: 1.5,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ].divide(const SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
