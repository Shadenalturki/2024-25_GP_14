import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:summ_a_ize/auth/firebase_auth/auth_util.dart';
import 'package:summ_a_ize/backend/constants.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chatbot_model.dart';

export 'chatbot_model.dart';

class ChatbotWidget extends StatefulWidget {
final String? topicId;
final String? sessionPdfId;


const ChatbotWidget({super.key, required this.sessionPdfId, required this.topicId});


  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late ChatbotModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> _messages = [];
  bool _isLoading = true;
  bool _isBotTyping = false;

  // Add a ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
      print("🧠 Chatbot INIT with topicId: ${widget.topicId}");

    _model = createModel(context, () => ChatbotModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Load previous chat messages when screen initializes
    _loadPreviousChat();
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Load previous chat messages from Firestore
  Future<void> _loadPreviousChat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (currentUserUid.isNotEmpty) {
   final chatRef = FirebaseFirestore.instance
    .collection('chats')
    .doc(currentUserUid)
    .collection('topics')
    .doc(widget.topicId)
    .collection('messages').where('timestamp', isGreaterThan: Timestamp(0, 0)) 
    .orderBy('timestamp', descending: false);




        final chatSnapshot = await chatRef.get();

        if (chatSnapshot.docs.isNotEmpty) {
          List<Map<String, String>> loadedMessages = [];

          for (var doc in chatSnapshot.docs) {
  final data = doc.data();

  if (data['role'] != null && data['message'] != null) {
    loadedMessages.add({
      "role": data['role'],
      "message": data['message'],
    });
  }
}


          setState(() {
            _messages = loadedMessages;
            _isLoading = false;
          });

          // Scroll to bottom after loading previous messages
          _scrollToBottom();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading previous chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save a message to Firestore
  Future<void> _saveMessageToFirestore(String role, String message) async {
    if (currentUserUid.isEmpty) return;

try {
    // 🔧 Save the document and capture its reference
    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUserUid)
        .collection('topics')
        .doc(widget.topicId)
        .collection('messages')
        .add({
      'role': role,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Now we can safely get the document to inspect it
   await Future.delayed(Duration(seconds: 1)); // wait a bit
final savedDoc = await docRef.get();
print("🔥 Saved Message Timestamp: ${savedDoc['timestamp']}");

  } catch (e) {
    print('Error saving message to Firestore: $e');
  }
  }

  Future<void> _sendMessage(String message) async {
    // Add user message to local state
    setState(() {
      _messages.add({"role": "user", "message": message});
      _isBotTyping = true; // Start loading animation
    });

    // Scroll to bottom after adding the user's message
    _scrollToBottom();

    // Save user message to Firestore
    await _saveMessageToFirestore("user", message);
    print("widget.sessionPdfId: ${widget.sessionPdfId}");

    // Send message to API
    final response = await http.post(
      Uri.parse('${ApiConstant.baseUrl}/chat'),
      headers: {'Content-Type': 'application/json'},
      body:
          json.encode({"question": message, "session_id": widget.sessionPdfId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final botResponse = data["answer"];

      // Add bot response to local state
      setState(() {
        _messages.add({"role": "bot", "message": botResponse});
        _isBotTyping = false; // Stop loading animation
      });

      // Scroll to bottom after adding the bot's response
      _scrollToBottom();

      // Save bot response to Firestore
      await _saveMessageToFirestore("bot", botResponse);
    } else {
      const errorMessage = "Failed to get a response from the bot.";

      // Add error message to local state
      setState(() {
        _messages.add({"role": "bot", "message": errorMessage});
        _isBotTyping = false; // Stop loading animation
      });

      // Scroll to bottom after adding the error message
      _scrollToBottom();

      // Save error message to Firestore
      await _saveMessageToFirestore("bot", errorMessage);
    }
  }

  Widget buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(35.0, 0.0, 0.0, 0.0),
              child: Align(
                alignment: const AlignmentDirectional(-0.9, 0.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 273.0),
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
                  // Updated padding around the three dots
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
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
      ],
    );
  }

  List<TextSpan> _parseText(String message, BuildContext context) {
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int start = 0;

    // Find all matches for text between **
    for (final match in regExp.allMatches(message)) {
      // Add text before the bold part
      if (match.start > start) {
        spans.add(TextSpan(text: message.substring(start, match.start)));
      }
      // The text between the ** markers
      final boldText = match.group(1);
      spans.add(
        TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }
    // Add remaining text after the last match
    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start)));
    }
    return spans;
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
          actions: [
            // Optional: Add a button to clear chat history
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () async {
                // Show confirmation dialog
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Clear Chat History?'),
                      content:
                          const Text('This will delete all previous messages.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldClear == true && currentUserUid.isNotEmpty) {
                  try {
                    // Delete all messages from Firestore
              final querySnapshot = await FirebaseFirestore.instance
  .collection('chats')
  .doc(currentUserUid)
  .collection('topics')
  .doc(widget.topicId)
  .collection('messages')
  .get();


for (var doc in querySnapshot.docs) {
  await doc.reference.delete();
}


                    // Clear local messages
                    setState(() {
                      _messages = [];
                    });
                  } catch (e) {
                    print('Error clearing chat history: $e');
                  }
                }
              },
            ),
          ],
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
                      const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 6.0, 10.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller:
                              _scrollController, // Attach the ScrollController
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Only show initial bot message if no previous messages exist
                              if (_messages.isEmpty)
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
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      padding: const EdgeInsets.all(12.0),
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

                              // Show typing indicator if bot is typing
                              if (_isBotTyping) buildTypingIndicator(),
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
            padding: const EdgeInsetsDirectional.fromSTEB(35.0, 0.0, 0.0, 0.0),
            child: Align(
              alignment: const AlignmentDirectional(-0.9, 0.0),
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
                  child: RichText(
                    text: TextSpan(
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: Colors.black,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            lineHeight: 1.3,
                          ),
                      children: _parseText(message, context),
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
