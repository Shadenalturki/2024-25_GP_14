import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
  final List<Map<String, String>> _messages = [];

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

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "message": message});
    });

    final response = await http.post(
      Uri.parse('https://f94f-110-39-21-190.ngrok-free.app/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"question": message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _messages.add({"role": "bot", "message": data["answer"]});
      });
    } else {
      setState(() {
        _messages.add({
          "role": "bot",
          "message": "Failed to get a response from the bot."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFFCFDFE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF104036),
          automaticallyImplyLeading: false,
          leading: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: FlutterFlowIconButton(
              buttonSize: 60.0,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () async {
                context.safePop();
              },
            ),
          ),
          title: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Row(
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
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'Inknut Antiqua',
                                color: Colors.white,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ],
                ),
              ],
            ),
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
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 6.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Initial bot message
                        buildBotWidget(
                          'Hello, I’m TutorBot! 👋 \nI’m your personal Studying assistant. \nHow can I help you?',
                        ),

                        // Chat messages
                        ..._messages.map((message) {
                          if (message["role"] == "user") {
                            // User message design
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFFFFF9F0), // Yellow container for user messages
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(35.0),
                                    bottomRight: Radius.circular(0.0),
                                    topLeft: Radius.circular(35.0),
                                    topRight: Radius.circular(35.0),
                                  ),
                                  border: Border.all(
                                    color: const Color(
                                        0xFFECE7DF), // Border for user messages
                                  ),
                                ),
                                child: Text(
                                  message["message"]!,
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
                            );
                          } else {
                            // Bot message - use buildBotWidget for consistent design
                            return buildBotWidget(message["message"]!);
                          }
                        }),
                        const SizedBox(height: 10)
                      ]
                          .divide(const SizedBox(height: 8.0))
                          .addToStart(const SizedBox(height: 10.0)),
                    ),
                  ),
                ),
              ),
              // Input field
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
                      Expanded(
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
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: Colors.black,
                                    letterSpacing: 0.0,
                                  ),
                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                          validator: _model.textControllerValidator
                              .asValidator(context),
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
                        onPressed: () async {
                          if (_model.textController.text.isNotEmpty) {
                            await _sendMessage(_model.textController.text);
                            _model.textController!.clear();
                          }
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

  Widget buildBotWidget(String message) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 0.0, 0.0),
            child: Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 273.0,
                ),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    message,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/chatbot.png',
              width: 35.0,
              height: 35.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
