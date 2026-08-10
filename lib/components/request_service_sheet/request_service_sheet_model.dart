import '/flutter_flow/flutter_flow_util.dart';
import 'request_service_sheet_widget.dart' show RequestServiceSheetWidget;
import 'package:flutter/material.dart';

class RequestServiceSheetModel extends FlutterFlowModel<RequestServiceSheetWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;

  DateTime? datePicked;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();
  }
}
