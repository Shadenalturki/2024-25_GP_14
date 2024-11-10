import '/auth/firebase_auth/auth_util.dart';

import '/backend/backend.dart';

import '/flutter_flow/flutter_flow_animations.dart';

import '/flutter_flow/flutter_flow_theme.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/flutter_flow/flutter_flow_widgets.dart';

import 'dart:math';

import 'sign_up_widget.dart' show SignUpWidget;

import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

class SignUpModel extends FlutterFlowModel<SignUpWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.

  TabController? tabBarController;

  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for userName widget.

  FocusNode? userNameFocusNode;

  TextEditingController? userNameTextController;

  String? Function(BuildContext, String?)? userNameTextControllerValidator;

  // State field(s) for email widget.

  FocusNode? emailFocusNode;

  TextEditingController? emailTextController;

  String? Function(BuildContext, String?)? emailTextControllerValidator;

  // State field(s) for passwordSignUp widget.

  FocusNode? passwordSignUpFocusNode;

  TextEditingController? passwordSignUpTextController;

  late bool passwordSignUpVisibility;

  String? Function(BuildContext, String?)?
      passwordSignUpTextControllerValidator;

  // State field(s) for confirmPassword widget.

  FocusNode? confirmPasswordFocusNode;

  TextEditingController? confirmPasswordTextController;

  late bool confirmPasswordVisibility; // Add this line

  // State field(s) for emailAddress widget.

  FocusNode? emailAddressFocusNode;

  TextEditingController? emailAddressTextController;

  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  // State field(s) for password widget.

  FocusNode? passwordFocusNode;

  TextEditingController? passwordTextController;

  late bool passwordVisibility;

  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordSignUpVisibility = false;

    passwordVisibility = false;

    confirmPasswordVisibility = false; // Initialize confirmPasswordVisibility

    // Initialize confirmPassword fields

    confirmPasswordFocusNode = FocusNode();

    confirmPasswordTextController = TextEditingController();
  }

  @override
  void dispose() {
    tabBarController?.dispose();

    userNameFocusNode?.dispose();

    userNameTextController?.dispose();

    emailFocusNode?.dispose();

    emailTextController?.dispose();

    passwordSignUpFocusNode?.dispose();

    passwordSignUpTextController?.dispose();

    confirmPasswordFocusNode?.dispose();

    confirmPasswordTextController?.dispose();

    emailAddressFocusNode?.dispose();

    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();

    passwordTextController?.dispose();
  }
}
