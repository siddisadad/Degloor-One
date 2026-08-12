import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'action_item_model.dart';
export 'action_item_model.dart';

class ActionItemWidget extends StatefulWidget {
  const ActionItemWidget({
    super.key,
    this.icon,
    Color? statusBg,
    String? statusLabel,
    Color? statusText,
    String? subtitle,
    String? title,
    this.onApprove,
    this.onReject,
  })  : statusBg = statusBg ?? const Color(0xFFFFF3E0),
        statusLabel = statusLabel ?? 'PENDING',
        statusText = statusText ?? const Color(0xFFE65100),
        subtitle = subtitle ?? 'Claimed by: Rajesh K.',
        title = title ?? 'Kulkarni Hardware';

  final Widget? icon;
  final Color statusBg;
  final String statusLabel;
  final Color statusText;
  final String subtitle;
  final String title;
  final Future Function()? onApprove;
  final Future Function()? onReject;

  @override
  State<ActionItemWidget> createState() => _ActionItemWidgetState();
}

class _ActionItemWidgetState extends State<ActionItemWidget> {
  late ActionItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActionItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: widget.icon,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget.title,
                        'Kulkarni Hardware',
                      ),
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context)
                          .bodyLarge
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .fontStyle,
                            lineHeight: 1.5,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget.subtitle,
                        'Claimed by: Rajesh K.',
                      ),
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context)
                          .bodySmall
                          .override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                            color:
                                FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                            lineHeight: 1.5,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ].divide(const SizedBox(height: 2.0)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: valueOrDefault<Color>(
                        widget.statusBg,
                        const Color(0xFFFFF3E0),
                      ),
                      borderRadius: BorderRadius.circular(9999.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 4.0, 12.0, 4.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget.statusLabel,
                          'PENDING',
                        ),
                        style: FlutterFlowTheme.of(context)
                            .labelSmall
                            .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: valueOrDefault<Color>(
                                widget.statusText,
                                const Color(0xFFE65100),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: Colors.transparent,
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          color: FlutterFlowTheme.of(context).success,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          if (widget.onApprove != null) {
                            await widget.onApprove!();
                          }
                        },
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: Colors.transparent,
                        icon: Icon(
                          Icons.highlight_off_rounded,
                          color: FlutterFlowTheme.of(context).error,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          if (widget.onReject != null) {
                            await widget.onReject!();
                          }
                        },
                      ),
                    ].divide(const SizedBox(width: 4.0)),
                  ),
                ].divide(const SizedBox(height: 8.0)),
              ),
            ].divide(const SizedBox(width: 16.0)),
          ),
        ),
      ),
    );
  }
}
