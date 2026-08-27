import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'button_model.dart';
export 'button_model.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    this.icon,
    bool? iconPresent,
    this.iconEnd,
    bool? iconEndPresent,
    String? content,
    String? variant,
    String? size,
    bool? fullWidth,
    bool? loading,
    bool? disabled,
    this.onTap,
  })  : iconPresent = iconPresent ?? false,
        iconEndPresent = iconEndPresent ?? false,
        content = content ?? 'Sign In',
        variant = variant ?? 'primary',
        size = size ?? 'small',
        fullWidth = fullWidth ?? true,
        loading = loading ?? false,
        disabled = disabled ?? false;

  final Widget? icon;
  final bool iconPresent;
  final Widget? iconEnd;
  final bool iconEndPresent;
  final String content;
  final String variant;
  final String size;
  final bool fullWidth;
  final bool loading;
  final bool disabled;
  final Future<void> Function()? onTap;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late ButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled || widget.onTap == null
          ? null
          : () {
              widget.onTap!();
            },
      child: Opacity(
        opacity: valueOrDefault<double>(
        valueOrDefault<bool>(
          widget.disabled,
          false,
        )
            ? 0.55
            : 1.0,
        1.0,
      ),
        child: Container(
        decoration: BoxDecoration(
          color: valueOrDefault<Color>(
            () {
              if (valueOrDefault<String>(
                    widget.variant,
                    'primary',
                  ) ==
                  'secondary') {
                return FlutterFlowTheme.of(context).secondary;
              } else if (valueOrDefault<String>(
                    widget.variant,
                    'primary',
                  ) ==
                  'outline') {
                return Colors.transparent;
              } else if (valueOrDefault<String>(
                    widget.variant,
                    'primary',
                  ) ==
                  'ghost') {
                return Colors.transparent;
              } else if (valueOrDefault<String>(
                    widget.variant,
                    'primary',
                  ) ==
                  'destructive') {
                return FlutterFlowTheme.of(context).error;
              } else {
                return FlutterFlowTheme.of(context).primary;
              }
            }(),
            FlutterFlowTheme.of(context).primary,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(valueOrDefault<double>(
              () {
                if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'small') {
                  return 4.0;
                } else if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'large') {
                  return 12.0;
                } else {
                  return 8.0;
                }
              }(),
              4.0,
            )),
            topRight: Radius.circular(valueOrDefault<double>(
              () {
                if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'small') {
                  return 4.0;
                } else if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'large') {
                  return 12.0;
                } else {
                  return 8.0;
                }
              }(),
              4.0,
            )),
            bottomLeft: Radius.circular(valueOrDefault<double>(
              () {
                if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'small') {
                  return 4.0;
                } else if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'large') {
                  return 12.0;
                } else {
                  return 8.0;
                }
              }(),
              4.0,
            )),
            bottomRight: Radius.circular(valueOrDefault<double>(
              () {
                if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'small') {
                  return 4.0;
                } else if (valueOrDefault<String>(
                      widget.size,
                      'small',
                    ) ==
                    'large') {
                  return 12.0;
                } else {
                  return 8.0;
                }
              }(),
              4.0,
            )),
          ),
          border: Border.all(
            color: valueOrDefault<Color>(
              valueOrDefault<String>(
                        widget.variant,
                        'primary',
                      ) ==
                      'outline'
                  ? FlutterFlowTheme.of(context).alternate
                  : Colors.transparent,
              Colors.transparent,
            ),
            width: valueOrDefault<double>(
              valueOrDefault<String>(
                        widget.variant,
                        'primary',
                      ) ==
                      'outline'
                  ? 1.0
                  : 0.0,
              0.0,
            ),
          ),
        ),
        child: Stack(
          alignment: const AlignmentDirectional(0.0, 0.0),
          children: [
            Opacity(
              opacity: valueOrDefault<double>(
                valueOrDefault<bool>(
                  widget.loading,
                  false,
                )
                    ? 0.0
                    : 1.0,
                1.0,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    valueOrDefault<double>(
                      () {
                        if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'small') {
                          return 16.0;
                        } else if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'large') {
                          return 32.0;
                        } else {
                          return 24.0;
                        }
                      }(),
                      16.0,
                    ),
                    valueOrDefault<double>(
                      () {
                        if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'small') {
                          return 4.0;
                        } else if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'large') {
                          return 16.0;
                        } else {
                          return 8.0;
                        }
                      }(),
                      4.0,
                    ),
                    valueOrDefault<double>(
                      () {
                        if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'small') {
                          return 16.0;
                        } else if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'large') {
                          return 32.0;
                        } else {
                          return 24.0;
                        }
                      }(),
                      16.0,
                    ),
                    valueOrDefault<double>(
                      () {
                        if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'small') {
                          return 4.0;
                        } else if (valueOrDefault<String>(
                              widget.size,
                              'small',
                            ) ==
                            'large') {
                          return 16.0;
                        } else {
                          return 8.0;
                        }
                      }(),
                      4.0,
                    )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (valueOrDefault<bool>(
                      widget.iconPresent,
                      false,
                    ))
                      widget.icon!,
                    Text(
                      valueOrDefault<String>(
                        widget.content,
                        'Sign In',
                      ),
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
                            color: valueOrDefault<Color>(
                              () {
                                if (valueOrDefault<String>(
                                      widget.variant,
                                      'primary',
                                    ) ==
                                    'secondary') {
                                  return FlutterFlowTheme.of(context)
                                      .onSecondary;
                                } else if (valueOrDefault<String>(
                                      widget.variant,
                                      'primary',
                                    ) ==
                                    'outline') {
                                  return FlutterFlowTheme.of(context)
                                      .primaryText;
                                } else if (valueOrDefault<String>(
                                      widget.variant,
                                      'primary',
                                    ) ==
                                    'ghost') {
                                  return FlutterFlowTheme.of(context).primary;
                                } else if (valueOrDefault<String>(
                                      widget.variant,
                                      'primary',
                                    ) ==
                                    'destructive') {
                                  return FlutterFlowTheme.of(context).onError;
                                } else {
                                  return FlutterFlowTheme.of(context).onPrimary;
                                }
                              }(),
                              FlutterFlowTheme.of(context).onPrimary,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                      overflow: TextOverflow.clip,
                    ),
                    if (valueOrDefault<bool>(
                      widget.iconEndPresent,
                      false,
                    ))
                      widget.iconEnd!,
                  ].divide(const SizedBox(width: 8.0)),
                ),
              ),
            ),
            if (valueOrDefault<bool>(
              valueOrDefault<bool>(
                widget.loading,
                false,
              )
                  ? true
                  : false,
              false,
            ))
              CircularPercentIndicator(
                radius: 7.0,
                lineWidth: 2.0,
                animation: true,
                animateFromLastPercent: true,
                progressColor: valueOrDefault<Color>(
                  () {
                    if (valueOrDefault<String>(
                          widget.variant,
                          'primary',
                        ) ==
                        'secondary') {
                      return FlutterFlowTheme.of(context).onSecondary;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'primary',
                        ) ==
                        'outline') {
                      return FlutterFlowTheme.of(context).primaryText;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'primary',
                        ) ==
                        'ghost') {
                      return FlutterFlowTheme.of(context).primary;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'primary',
                        ) ==
                        'destructive') {
                      return FlutterFlowTheme.of(context).onError;
                    } else {
                      return FlutterFlowTheme.of(context).onPrimary;
                    }
                  }(),
                  FlutterFlowTheme.of(context).onPrimary,
                ),
                backgroundColor: FlutterFlowTheme.of(context).alternate,
              ),
          ],
        ),
      ),
    ),
  );
}
}
