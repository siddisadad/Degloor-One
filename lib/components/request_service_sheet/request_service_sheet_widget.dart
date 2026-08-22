import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'request_service_sheet_model.dart';
export 'request_service_sheet_model.dart';

class RequestServiceSheetWidget extends StatefulWidget {
  const RequestServiceSheetWidget({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  final String providerId;
  final String providerName;

  @override
  State<RequestServiceSheetWidget> createState() =>
      _RequestServiceSheetWidgetState();
}

class _RequestServiceSheetWidgetState extends State<RequestServiceSheetWidget> {
  late RequestServiceSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestServiceSheetModel());

    _model.descriptionTextController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _model.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Service from ${widget.providerName}',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _model.descriptionTextController,
                focusNode: _model.descriptionFocusNode,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'Describe what you need help with...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () async {
                  final datePickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );

                  if (datePickedDate != null) {
                    if (!context.mounted) return;
                    final datePickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    );
                    if (datePickedTime != null) {
                      if (!context.mounted) return;
                      setState(() {
                        _model.datePicked = DateTime(
                          datePickedDate.year,
                          datePickedDate.month,
                          datePickedDate.day,
                          datePickedTime.hour,
                          datePickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _model.datePicked == null
                            ? 'Select Schedule Date'
                            : dateTimeFormat('MMMMEEEEd', _model.datePicked),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      Icon(Icons.calendar_today,
                          color: FlutterFlowTheme.of(context).secondaryText),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              FFButtonWidget(
                onPressed: () async {
                  if (_model.formKey.currentState!.validate()) {
                    if (_model.datePicked == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                      return;
                    }

                    await ServiceMarketplaceService.instance.createRequest(
                      userId: currentUserUid,
                      providerId: widget.providerId,
                      description:
                          _model.descriptionTextController?.text ?? '',
                      scheduledAt: _model.datePicked!,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service request sent successfully!')),
                    );
                  }
                },
                text: 'Send Request',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
