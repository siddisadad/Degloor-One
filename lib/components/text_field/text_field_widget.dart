import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'text_field_model.dart';
export 'text_field_model.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    String? label,
    bool? labelPresent,
    String? helper,
    bool? helperPresent,
    this.leadingIcon,
    bool? leadingIconPresent,
    this.trailingIcon,
    bool? trailingIconPresent,
    String? hint,
    String? value,
    this.onChange,
    this.onSubmit,
    String? variant,
    bool? error,
    this.obscureText = false,
  })  : label = label ?? '',
        labelPresent = labelPresent ?? false,
        helper = helper ?? '',
        helperPresent = helperPresent ?? false,
        leadingIconPresent = leadingIconPresent ?? false,
        trailingIconPresent = trailingIconPresent ?? false,
        hint = hint ?? 'Enter 10 digit mobile number',
        value = value ?? '',
        variant = variant ?? 'filled',
        error = error ?? false;

  final String label;
  final bool labelPresent;
  final String helper;
  final bool helperPresent;
  final Widget? leadingIcon;
  final bool leadingIconPresent;
  final Widget? trailingIcon;
  final bool trailingIconPresent;
  final String hint;
  final String value;
  final Function(String)? onChange;
  final Function(String)? onSubmit;
  final String variant;
  final bool error;
  final bool obscureText;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextFieldModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextFieldModel());

    _model.inputTextController ??= TextEditingController(text: widget.value);
    _model.inputFocusNode ??= FocusNode();
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (valueOrDefault<bool>(
          widget.labelPresent,
          false,
        ))
          Text(
            widget.label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<bool>(
                      widget.error,
                      false,
                    )
                        ? FlutterFlowTheme.of(context).error
                        : FlutterFlowTheme.of(context).primaryText,
                    FlutterFlowTheme.of(context).primaryText,
                  ),
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  lineHeight: 1.4,
                ),
          ),
        Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: valueOrDefault<Color>(
              () {
                if (valueOrDefault<String>(
                      widget.variant,
                      'filled',
                    ) ==
                    'filled') {
                  return FlutterFlowTheme.of(context).secondaryBackground;
                } else if (valueOrDefault<String>(
                      widget.variant,
                      'filled',
                    ) ==
                    'ghost') {
                  return Colors.transparent;
                } else {
                  return Colors.transparent;
                }
              }(),
              FlutterFlowTheme.of(context).secondaryBackground,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(valueOrDefault<double>(
                () {
                  if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return 4.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return 4.0;
                  } else {
                    return 4.0;
                  }
                }(),
                4.0,
              )),
              topRight: Radius.circular(valueOrDefault<double>(
                () {
                  if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return 4.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return 4.0;
                  } else {
                    return 4.0;
                  }
                }(),
                4.0,
              )),
              bottomLeft: Radius.circular(valueOrDefault<double>(
                () {
                  if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return 4.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return 4.0;
                  } else {
                    return 4.0;
                  }
                }(),
                4.0,
              )),
              bottomRight: Radius.circular(valueOrDefault<double>(
                () {
                  if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return 4.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return 4.0;
                  } else {
                    return 4.0;
                  }
                }(),
                4.0,
              )),
            ),
            border: Border.all(
              color: valueOrDefault<Color>(
                () {
                  if (valueOrDefault<bool>(
                    widget.error,
                    false,
                  )) {
                    return FlutterFlowTheme.of(context).error;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return Colors.transparent;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return Colors.transparent;
                  } else {
                    return FlutterFlowTheme.of(context).alternate;
                  }
                }(),
                Colors.transparent,
              ),
              width: valueOrDefault<double>(
                () {
                  if (valueOrDefault<bool>(
                    widget.error,
                    false,
                  )) {
                    return 1.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'filled') {
                    return 1.0;
                  } else if (valueOrDefault<String>(
                        widget.variant,
                        'filled',
                      ) ==
                      'ghost') {
                    return 0.0;
                  } else {
                    return 1.0;
                  }
                }(),
                1.0,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  () {
                    if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'filled') {
                      return 8.0;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'ghost') {
                      return 8.0;
                    } else {
                      return 8.0;
                    }
                  }(),
                  8.0,
                ),
                valueOrDefault<double>(
                  () {
                    if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'filled') {
                      return 8.0;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'ghost') {
                      return 8.0;
                    } else {
                      return 8.0;
                    }
                  }(),
                  8.0,
                ),
                valueOrDefault<double>(
                  () {
                    if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'filled') {
                      return 8.0;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'ghost') {
                      return 8.0;
                    } else {
                      return 8.0;
                    }
                  }(),
                  8.0,
                ),
                valueOrDefault<double>(
                  () {
                    if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'filled') {
                      return 8.0;
                    } else if (valueOrDefault<String>(
                          widget.variant,
                          'filled',
                        ) ==
                        'ghost') {
                      return 8.0;
                    } else {
                      return 8.0;
                    }
                  }(),
                  8.0,
                )),
            child: Row(
              children: [
                if (valueOrDefault<bool>(
                      widget.leadingIconPresent,
                      false,
                    ) &&
                    widget.leadingIcon != null)
                  widget.leadingIcon!,
                Expanded(
                  child: TextFormField(
                    controller: _model.inputTextController,
                    focusNode: _model.inputFocusNode,
                    onChanged: (val) => widget.onChange?.call(val),
                    onFieldSubmitted: (val) => widget.onSubmit?.call(val),
                    obscureText: widget.obscureText,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: valueOrDefault<String>(
                        widget.hint,
                        'Enter 10 digit mobile number',
                      ),
                      hintStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: valueOrDefault<Color>(
                              () {
                                if (valueOrDefault<String>(
                                      widget.variant,
                                      'filled',
                                    ) ==
                                    'filled') {
                                  return FlutterFlowTheme.of(context).accent3;
                                } else if (valueOrDefault<String>(
                                      widget.variant,
                                      'filled',
                                    ) ==
                                    'ghost') {
                                  return FlutterFlowTheme.of(context).accent3;
                                } else {
                                  return FlutterFlowTheme.of(context).accent3;
                                }
                              }(),
                              FlutterFlowTheme.of(context).accent3,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.5,
                          ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: valueOrDefault<Color>(
                            () {
                              if (valueOrDefault<String>(
                                    widget.variant,
                                    'filled',
                                  ) ==
                                  'filled') {
                                return FlutterFlowTheme.of(context)
                                    .primaryText;
                              } else if (valueOrDefault<String>(
                                    widget.variant,
                                    'filled',
                                  ) ==
                                  'ghost') {
                                return FlutterFlowTheme.of(context)
                                    .primaryText;
                              } else {
                                return FlutterFlowTheme.of(context)
                                    .primaryText;
                              }
                            }(),
                            FlutterFlowTheme.of(context).primaryText,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontStyle,
                          lineHeight: 1.5,
                        ),
                    validator: _model.inputTextControllerValidator
                        .asValidator(context),
                  ),
                ),
                if (valueOrDefault<bool>(
                      widget.trailingIconPresent,
                      false,
                    ) &&
                    widget.trailingIcon != null)
                  widget.trailingIcon!,
              ],
            ),
          ),
        ),
        if (valueOrDefault<bool>(
          widget.helperPresent,
          false,
        ))
          Text(
            widget.helper,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<bool>(
                      widget.error,
                      false,
                    )
                        ? FlutterFlowTheme.of(context).error
                        : FlutterFlowTheme.of(context).secondaryText,
                    FlutterFlowTheme.of(context).secondaryText,
                  ),
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).bodySmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  lineHeight: 1.5,
                ),
          ),
      ].divide(const SizedBox(height: 6.0)),
    );
  }
}
