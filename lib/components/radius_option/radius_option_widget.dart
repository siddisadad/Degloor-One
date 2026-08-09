import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'radius_option_model.dart';
export 'radius_option_model.dart';

class RadiusOptionWidget extends StatefulWidget {
  const RadiusOptionWidget({
    super.key,
    String? value,
    bool? selected,
  })  : this.value = value ?? '2',
        this.selected = selected ?? false;

  final String value;
  final bool selected;

  @override
  State<RadiusOptionWidget> createState() => _RadiusOptionWidgetState();
}

class _RadiusOptionWidgetState extends State<RadiusOptionWidget> {
  late RadiusOptionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RadiusOptionModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          valueOrDefault<bool>(
            widget.selected,
            false,
          )
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          FlutterFlowTheme.of(context).secondaryBackground,
        ),
        borderRadius: BorderRadius.circular(8.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: valueOrDefault<Color>(
            valueOrDefault<bool>(
              widget.selected,
              false,
            )
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            FlutterFlowTheme.of(context).alternate,
          ),
          width: valueOrDefault<double>(
            valueOrDefault<bool>(
              widget.selected,
              false,
            )
                ? 1.0
                : 1.0,
            1.0,
          ),
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        valueOrDefault<String>(
          '${widget.value} KM',
          '2 KM',
        ),
        style: FlutterFlowTheme.of(context).labelLarge.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
              ),
              color: valueOrDefault<Color>(
                valueOrDefault<bool>(
                  widget.selected,
                  false,
                )
                    ? FlutterFlowTheme.of(context).onPrimary
                    : FlutterFlowTheme.of(context).primaryText,
                FlutterFlowTheme.of(context).primaryText,
              ),
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
              lineHeight: 1.4,
            ),
      ),
    );
  }
}
