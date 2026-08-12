import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'slider_model.dart';
export 'slider_model.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({
    super.key,
    String? label,
    bool? labelPresent,
    String? description,
    bool? descriptionPresent,
    String? valueLabel,
    bool? valueLabelPresent,
    double? step,
    int? divisions,
    double? valuePercentage,
    Color? color,
    String? variant,
    bool? disabled,
    bool? showTicks,
  })  : label = label ?? '',
        labelPresent = labelPresent ?? false,
        description = description ?? '',
        descriptionPresent = descriptionPresent ?? false,
        valueLabel = valueLabel ?? '',
        valueLabelPresent = valueLabelPresent ?? false,
        step = step ?? 0.0,
        divisions = divisions ?? 12,
        valuePercentage = valuePercentage ?? 34.78260869565217,
        color = color ?? const Color(0x00000000),
        variant = variant ?? 'Material',
        disabled = disabled ?? false,
        showTicks = showTicks ?? true;

  final String label;
  final bool labelPresent;
  final String description;
  final bool descriptionPresent;
  final String valueLabel;
  final bool valueLabelPresent;
  final double step;
  final int divisions;
  final double valuePercentage;
  final Color color;
  final String variant;
  final bool disabled;
  final bool showTicks;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late SliderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SliderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: valueOrDefault<double>(
        valueOrDefault<bool>(
          widget.disabled,
          false,
        )
            ? 0.55
            : 1.0,
        1.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (valueOrDefault<bool>(
                widget.labelPresent,
                false,
              ))
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontStyle,
                          lineHeight: 1.4,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (valueOrDefault<bool>(
                widget.valueLabelPresent,
                false,
              ))
                Text(
                  widget.valueLabel,
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight: FlutterFlowTheme.of(context)
                            .labelMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .labelMedium
                            .fontStyle,
                        lineHeight: 1.4,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
            ].divide(const SizedBox(width: 16.0)),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  valueOrDefault<String>(
                            widget.variant,
                            'Material',
                          ) ==
                          'iOS'
                      ? 0.0
                      : 0.0,
                  0.0,
                ),
                valueOrDefault<double>(
                  valueOrDefault<String>(
                            widget.variant,
                            'Material',
                          ) ==
                          'iOS'
                      ? 0.0
                      : 8.0,
                  8.0,
                ),
                valueOrDefault<double>(
                  valueOrDefault<String>(
                            widget.variant,
                            'Material',
                          ) ==
                          'iOS'
                      ? 0.0
                      : 0.0,
                  0.0,
                ),
                valueOrDefault<double>(
                  valueOrDefault<String>(
                            widget.variant,
                            'Material',
                          ) ==
                          'iOS'
                      ? 0.0
                      : 8.0,
                  8.0,
                )),
            child: Slider(
              activeColor: valueOrDefault<Color>(
                widget.color,
                FlutterFlowTheme.of(context).primary,
              ),
              inactiveColor: FlutterFlowTheme.of(context).alternate,
              max: 100.0,
              value: _model.sliderValue ??= valueOrDefault<double>(
                widget.valuePercentage,
                34.78260869565217,
              ),
              onChanged: (newValue) {
                newValue = double.parse(newValue.toStringAsFixed(2));
                safeSetState(() => _model.sliderValue = newValue);
              },
            ),
          ),
          if (valueOrDefault<bool>(
            widget.descriptionPresent,
            false,
          ))
            Text(
              widget.description,
              maxLines: 2,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    lineHeight: 1.5,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
        ].divide(const SizedBox(height: 4.0)),
      ),
    );
  }
}
