import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filter_chip_model.dart';
export 'filter_chip_model.dart';

class FilterChipWidget extends StatefulWidget {
  const FilterChipWidget({
    super.key,
    bool? hasIcon,
    String? label,
    bool? selected,
    this.onTap,
  })  : hasIcon = hasIcon ?? true,
        label = label ?? '10 km',
        selected = selected ?? true;

  final bool hasIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  late FilterChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FilterChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: valueOrDefault<Color>(
              valueOrDefault<bool>(
                widget.selected,
                true,
              )
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondaryBackground,
              FlutterFlowTheme.of(context).primary,
            ),
            borderRadius: BorderRadius.circular(9999.0),
            border: Border.all(
              color: valueOrDefault<Color>(
                valueOrDefault<bool>(
                  widget.selected,
                  true,
                )
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).alternate,
                FlutterFlowTheme.of(context).primary,
              ),
              width: valueOrDefault<double>(
                valueOrDefault<bool>(
                  widget.selected,
                  true,
                )
                    ? 1.0
                    : 1.0,
                1.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
            child: Row(
              children: [
                Text(
                  valueOrDefault<String>(
                    widget.label,
                    '10 km',
                  ),
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontStyle,
                        ),
                        color: valueOrDefault<Color>(
                          valueOrDefault<bool>(
                            widget.selected,
                            true,
                          )
                              ? FlutterFlowTheme.of(context).onPrimary
                              : FlutterFlowTheme.of(context).secondaryText,
                          FlutterFlowTheme.of(context).onPrimary,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelLarge.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
                if (valueOrDefault<bool>(
                  widget.hasIcon,
                  true,
                ))
                  SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: Stack(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      children: [
                        if (valueOrDefault<bool>(
                          valueOrDefault<bool>(
                            widget.selected,
                            true,
                          )
                              ? true
                              : false,
                          true,
                        ))
                          Icon(
                            Icons.close_rounded,
                            color: valueOrDefault<Color>(
                              valueOrDefault<bool>(
                                widget.selected,
                                true,
                              )
                                  ? FlutterFlowTheme.of(context).onPrimary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryText,
                              FlutterFlowTheme.of(context).onPrimary,
                            ),
                            size: 16.0,
                          ),
                        if (valueOrDefault<bool>(
                          valueOrDefault<bool>(
                            widget.selected,
                            true,
                          )
                              ? false
                              : true,
                          false,
                        ))
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: valueOrDefault<Color>(
                              valueOrDefault<bool>(
                                widget.selected,
                                true,
                              )
                                  ? FlutterFlowTheme.of(context).onPrimary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryText,
                              FlutterFlowTheme.of(context).onPrimary,
                            ),
                            size: 16.0,
                          ),
                      ],
                    ),
                  ),
              ].divide(const SizedBox(width: 4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
