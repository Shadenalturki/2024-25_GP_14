import '/flutter_flow/flutter_flow_util.dart';
import 'forgotpassword_widget.dart' show ForgotpasswordWidget;
import 'package:flutter/material.dart';

class ForgotpasswordModel extends FlutterFlowModel<ForgotpasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for forgotemail widget.
  FocusNode? forgotemailFocusNode;
  TextEditingController? forgotemailTextController;
  String? Function(BuildContext, String?)? forgotemailTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    forgotemailFocusNode?.dispose();
    forgotemailTextController?.dispose();
  }
}
