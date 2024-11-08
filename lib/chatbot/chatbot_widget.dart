import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chatbot_model.dart';
export 'chatbot_model.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late ChatbotModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatbotModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
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
        backgroundColor: const Color(0xFFFCFDFE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFEFEFE),
          automaticallyImplyLeading: false,
          leading: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: FlutterFlowIconButton(
              borderColor: const Color(0xFFE3E5E5),
              borderRadius: 80.0,
              borderWidth: 2.0,
              buttonSize: 40.0,
              fillColor: const Color(0x00F8B038),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Color(0xFF72777A),
                size: 24.0,
              ),
              onPressed: () async {
                context.safePop();
              },
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/ai-assistant.png',
                  width: 57.0,
                  height: 50.0,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'TutorBot',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Inter Tight',
                          color: const Color(0xFF202325),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.circle_rounded,
                        color: Color(0xFF7DDE86),
                        size: 8.0,
                      ),
                      Text(
                        'Always active',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: const Color(0xFF72777A),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ]
                        .divide(const SizedBox(width: 4.0))
                        .addToStart(const SizedBox(width: 7.0)),
                  ),
                ],
              ),
            ],
          ),
          actions: const [],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 6.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 179.0,
                          child: Stack(
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(0.95, 0.97),
                                child: Container(
                                  width: 145.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9F0),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(35.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(35.0),
                                      topRight: Radius.circular(35.0),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFECE7DF),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: const AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Explain what is AI ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                            fontSize: 13.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.98, -0.98),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/chatbot.png',
                                    width: 35.0,
                                    height: 35.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.5, 0.13),
                                child: Container(
                                  width: 273.0,
                                  height: 91.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1EEEB),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(35.0),
                                      bottomRight: Radius.circular(35.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(35.0),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFD4DFDD),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: const AlignmentDirectional(0.0, -0.42),
                                    child: Text(
                                      'Hello, I’m TutorBot! 👋 \nI’m your personal Stadying assistant. \nHow can I help you?',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, -1.0),
                          child: SizedBox(
                            height: 171.0,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0.95, 1.1),
                                  child: Container(
                                    width: 145.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9F0),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(35.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(35.0),
                                        topRight: Radius.circular(35.0),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFECE7DF),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        'Give me examples ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Colors.black,
                                              fontSize: 13.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.5, 0.13),
                                  child: Container(
                                    width: 273.0,
                                    height: 103.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1EEEB),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(35.0),
                                        bottomRight: Radius.circular(35.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(35.0),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFD4DFDD),
                                      ),
                                    ),
                                    alignment: const AlignmentDirectional(0.0, 0.0),
                                    child: Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, -0.42),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            9.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          'Artificial Intelligence (AI) is a way of making computers intelligent, making computers capable of doing things that generally require human intelligence',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.98, -0.98),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/chatbot.png',
                                      width: 35.0,
                                      height: 35.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 155.0,
                          child: Stack(
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-0.39, 0.41),
                                child: Container(
                                  width: 285.0,
                                  height: 104.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1EEEB),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(35.0),
                                      bottomRight: Radius.circular(35.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(35.0),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFD4DFDD),
                                    ),
                                  ),
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Align(
                                    alignment: const AlignmentDirectional(0.0, -0.42),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          9.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Here is some AI examples: Manufacturing robots, Self-driving cars, Smart assistants, Healthcare management, Automated financial investingVirtual travel booking agent.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.98, -0.98),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/chatbot.png',
                                    width: 35.0,
                                    height: 35.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                          .divide(const SizedBox(height: 8.0))
                          .addToStart(const SizedBox(height: 10.0)),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Container(
                  width: 346.0,
                  height: 37.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(18.0),
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: const Color(0xFF656464),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(-1.0, -1.0),
                        child: SizedBox(
                          width: 300.0,
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF070707),
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Type a message...',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF727171),
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textControllerValidator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: const Color(0x00F8B038),
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF6B6A6A),
                          size: 24.0,
                        ),
                        onPressed: () {
                          print('IconButton pressed ...');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
