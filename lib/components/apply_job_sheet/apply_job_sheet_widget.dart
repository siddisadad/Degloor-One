import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/shared/job_application_draft.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_model.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:degloor_one/components/apply_job_sheet/apply_job_sheet_model.dart';
export 'package:degloor_one/components/apply_job_sheet/apply_job_sheet_model.dart';

class ApplyJobSheetWidget extends StatefulWidget {
  const ApplyJobSheetWidget({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  final String jobId;
  final String jobTitle;

  @override
  State<ApplyJobSheetWidget> createState() => _ApplyJobSheetWidgetState();
}

class _ApplyJobSheetWidgetState extends State<ApplyJobSheetWidget> {
  late ApplyJobSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ApplyJobSheetModel());

    _model.experienceController ??= TextEditingController();
    _model.experienceFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: DegloorTheme.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for Position',
                          style: DegloorTheme.headingMedium,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            widget.jobTitle,
                            style: DegloorTheme.bodyMedium.copyWith(
                                  color: DegloorTheme.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: DegloorTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: Text(
                  'Experience Summary',
                  style: DegloorTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Text(
                  'Briefly describe your relevant experience for this role.',
                  style: DegloorTheme.bodyMedium.copyWith(
                        color: DegloorTheme.textSecondary,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: TextFormField(
                  controller: _model.experienceController,
                  focusNode: _model.experienceFocusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'I have 2 years of experience in...',
                    hintStyle: DegloorTheme.labelMedium,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: DegloorTheme.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: DegloorTheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: DegloorTheme.error,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: DegloorTheme.error,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: DegloorTheme.background,
                  ),
                  style: DegloorTheme.bodyMedium,
                  maxLines: 5,
                  validator: _model.experienceControllerValidator.asValidator(context),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                child: FFButtonWidget(
                  onPressed: () async {
                    if (_model.experienceController!.text.trim().length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please provide a more detailed experience summary (min 10 characters)',
                          ),
                          backgroundColor: DegloorTheme.error,
                        ),
                      );
                      return;
                    }

                    try {
                      await JobService.instance.apply(
                        JobApplicationDraft.fromForm(
                          jobId: widget.jobId,
                          applicantId: currentUserUid,
                          experienceSummary: _model.experienceController!.text,
                        ),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Application submitted successfully!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: DegloorTheme.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLogger.userFacingMessage(
                                e,
                                fallback:
                                    'Unable to submit the application. Please try again.',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: DegloorTheme.error,
                          ),
                        );
                      }
                    }
                  },
                  text: 'Submit Application',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: DegloorTheme.primary,
                    textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    elevation: 0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
