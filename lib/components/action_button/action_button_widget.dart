import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'action_button_model.dart';
export 'action_button_model.dart';

class ActionButtonWidget extends StatefulWidget {
  const ActionButtonWidget({
    super.key,
    Color? bg,
    Color? borderColor,
    Color? color,
    this.icon,
    String? label,
    this.onTap,
  })  : this.bg = bg ?? const Color(0x00000000),
        this.borderColor = borderColor ?? const Color(0x00000000),
        this.color = color ?? const Color(0x00000000),
        this.label = label ?? 'Call';

  final Color bg;
  final Color borderColor;
  final Color color;
  final Widget? icon;
  final String label;
  final Future<void> Function()? onTap;

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  late ActionButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActionButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: valueOrDefault<Color>(
            widget.bg,
            FlutterFlowTheme.of(context).primaryContainer,
          ),
          borderRadius: BorderRadius.circular(8.0),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.icon!,
                Text(
                  valueOrDefault<String>(
                    widget.label,
                    'Call',
                  ),
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                        color: valueOrDefault<Color>(
                          widget.color,
                          FlutterFlowTheme.of(context).primary,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        lineHeight: 1.2,
                      ),
                ),
              ].divide(SizedBox(height: 4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
