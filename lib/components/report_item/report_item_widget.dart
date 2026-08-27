import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'report_item_model.dart';
export 'report_item_model.dart';

class ReportItemWidget extends StatefulWidget {
  const ReportItemWidget({
    super.key,
    String? businessName,
    String? date,
    String? reason,
    String? status,
  })  : businessName = businessName ?? 'Degloor Hardware Store',
        date = date ?? '2 hours ago',
        reason = reason ??
            'Incorrect opening hours listed. Store is closed on Tuesdays.',
        status = status ?? 'pending';

  final String businessName;
  final String date;
  final String reason;
  final String status;

  @override
  State<ReportItemWidget> createState() => _ReportItemWidgetState();
}

class _ReportItemWidgetState extends State<ReportItemWidget> {
  late ReportItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportItemModel());
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: valueOrDefault<Color>(
                        valueOrDefault<String>(
                                  widget.status,
                                  'pending',
                                ) ==
                                'resolved'
                            ? FlutterFlowTheme.of(context).success
                            : FlutterFlowTheme.of(context).tertiary,
                        FlutterFlowTheme.of(context).tertiary,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          8.0, 4.0, 8.0, 4.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget.status,
                          'pending',
                        ).toUpperCase(),
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily: 'Inter',
                              color: widget.status == 'resolved'
                                  ? FlutterFlowTheme.of(context).onSuccess
                                  : FlutterFlowTheme.of(context).primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      valueOrDefault<String>(
                        widget.date,
                        '2 hours ago',
                      ),
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                valueOrDefault<String>(
                  widget.businessName,
                  'Degloor Hardware Store',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                valueOrDefault<String>(
                  widget.reason,
                  'Incorrect opening hours listed. Store is closed on Tuesdays.',
                ),
                maxLines: 2,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ].divide(const SizedBox(height: 8.0)),
          ),
        ),
      ),
    );
  }
}
