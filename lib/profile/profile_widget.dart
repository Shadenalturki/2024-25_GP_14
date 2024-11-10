import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_model.dart';
export 'profile_model.dart';
import '../sign_up/sign_up_widget.dart'; // Ensure correct import path
import '/flutter_flow/flutter_flow_theme.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF104036),
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'Profile',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Inknut Antiqua',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          elevation: 2,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/My_Message.png',
                                width: 180,
                                height: 94,
                                fit: BoxFit.contain,
                                alignment: const Alignment(0, -0.5),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment(-0.18, -0.37),
                            child: Text(
                              'Account Information',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/chatbot.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              _buildUserInfoTile(currentUserDisplayName),
              _buildUserInfoTile(currentUserEmail),
              const SizedBox(height: 8),
              FFButtonWidget(
                onPressed: () async {
                  bool confirmDialogResponse = await showDialog<bool>(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Logout'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(alertDialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(alertDialogContext, true);
                                  await authManager.signOut();
                                  GoRouter.of(context).go('/signUp');
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;
                },
                text: 'Log out',
                icon: const Icon(
                  Icons.login_outlined,
                  size: 25,
                ),
                options: FFButtonOptions(
                  width: 190,
                  height: 53,
                  color: const Color(0xFF104036),
                  textStyle: const TextStyle(
                    fontFamily: 'DM Sans',
                    color: Color(0xFFF8F6F6),
                    fontSize: 18,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoTile(String info) {
    return Container(
      width: 353,
      height: 66,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        info,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          color: Color(0xFF202325),
          fontSize: 20,
        ),
      ),
    );
  }
}
