import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'summary_quiz_model.dart';
export 'summary_quiz_model.dart';
import 'package:http/http.dart' as http; // Add this line for HTTP requests
import 'dart:convert'; // Add this line to decode JSON responses

class SummaryQuizWidget extends StatefulWidget {
  final String summary;

  const SummaryQuizWidget({required this.summary, super.key});

  @override
  State<SummaryQuizWidget> createState() => _SummaryQuizWidgetState();
}

class _SummaryQuizWidgetState extends State<SummaryQuizWidget> {
  late SummaryQuizModel _model;
  String? translatedSummary; // Add this local variable
  bool showTranslated = false; // Toggle to track which text to show
  String? summary;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SummaryQuizModel());
    translatedSummary = widget.summary; // Initialize with the original summary
    summary = widget.summary;
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _translateSummary() async {
      print("Translation button pressed");  // This should show up in the console when the button is clicked

  // Toggle the view between original and translated text
  if (showTranslated) {
        print("Toggling to show original text");
    setState(() {
      showTranslated = false;  // Show original text
    });
    return;
  }

  // If translatedSummary is already set and just needs to be shown
  if (translatedSummary != null && translatedSummary != widget.summary) {
        print("Toggling to show translated text");
    setState(() {
      showTranslated = true;  // Show translated text
    });
    return;
  }

  // Fetch translation only if it's not already loaded
  const apiUrl = 'https://summarize.ngrok-free.app/translate';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": widget.summary}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('translated_summary')) {
        setState(() {
          translatedSummary = responseData['translated_summary'];
          showTranslated = true;  // Toggle to show translated text
        });
      } else {
        throw Exception('Response does not contain translated_summary');
      }
    } else {
      throw Exception('Failed to translate summary');
    }
  } catch (e) {
    print('Error during translation: $e');
    setState(() {
      translatedSummary = "Error in translation!";
      showTranslated = true;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFFAFAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF104036),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'SummAIze Notebook',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inknut Antiqua',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(-0.9, -0.9),
                              child: Text(
                                'Topic',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'DM Sans',
                                      color: Colors.black,
                                      fontSize: 25.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 352.0,
                            height: 384.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1EEEB),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(25.0),
                                bottomRight: Radius.circular(25.0),
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-0.9, -0.85),
                                  child: Text(
                                    'Summary',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'DM Sans',
                                          color: Color(0xFF202325),
                                          fontSize: 18,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                
                                Positioned(
                                  top: 80, // Adjust positioning
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Add padding around the text
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFFE1EEEB), // Light green background
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth:
                                            600.0, // Constrain the box width
                                        minHeight: 100.0, // Minimum height
                                        maxHeight: 290.0, // Maximum height
                                      ),
                                      padding: const EdgeInsets.fromLTRB(16.0,
                                          1.0, 16.0, 1.0), // Inner padding
                                      child: SingleChildScrollView(
                                        child: Text(
                                          showTranslated ? translatedSummary ?? "Translation error" : widget.summary,
                                          /*translatedSummary ??
                                              widget.summary ??
                                              "No summary available",*/ // Use translated summary or fallback to the original
                                          textAlign: TextAlign.start, // Align text to the start
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.91, -0.79),
                                  child: Container(
                                    width: 46.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC4DED7),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4.0,
                                          color: Color(0x33000000),
                                          offset: Offset(
                                            0.0,
                                            2.0,
                                          ),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.88, -0.76),
                                  child: InkWell(
                                    onTap:_translateSummary, // Call the translation function
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                      child: Image.asset(
                                        'assets/images/arabic.png',
                                        width: 35.0,
                                        height: 35.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.5),
                          child: Container(
                            width: 352.0,
                            height: 62.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF3E1),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(25.0),
                                bottomRight: Radius.circular(25.0),
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-0.9, -0.53),
                                  child: Text(
                                    'Quiz time!',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'DM Sans',
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.89, -0.01),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed('Quiz');
                                    },
                                    child: Container(
                                      width: 46.0,
                                      height: 45.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0x77E5D6BD),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: Color(0x33838282),
                                            offset: Offset(
                                              0.0,
                                              2.0,
                                            ),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            'Quiz',
                                            extra: <String, dynamic>{
                                              kTransitionInfoKey:
                                                  const TransitionInfo(
                                                hasTransition: true,
                                                transitionType:
                                                    PageTransitionType.fade,
                                                duration:
                                                    Duration(milliseconds: 0),
                                              ),
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.quiz_outlined,
                                          color: Colors.black,
                                          size: 25.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 8.0)),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.85, 0.97),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed('chatbot');
                  },
                  child: Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFBFD5CB),
                      ),
                    ),
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text(
                          'Tutor Bot',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF104036),
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
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
