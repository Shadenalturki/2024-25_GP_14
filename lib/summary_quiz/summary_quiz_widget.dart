import 'package:summ_a_ize/flutter_flow/flutter_flow_radio_button.dart';
import 'package:summ_a_ize/flutter_flow/flutter_flow_widgets.dart';
import 'package:summ_a_ize/flutter_flow/form_field_controller.dart';

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
  final String topicName;
  final List quizData;
  const SummaryQuizWidget(
      {required this.summary,
      required this.topicName,
      super.key,
      required this.quizData});

  @override
  State<SummaryQuizWidget> createState() => _SummaryQuizWidgetState();
}

class _SummaryQuizWidgetState extends State<SummaryQuizWidget> {
  late SummaryQuizModel _model;
  String? translatedSummary; // Add this local variable
  bool showTranslated = false; // Toggle to track which text to show
  String? summary;
  List? quizData;
  String? topicName;
  String resultMessage = "";
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SummaryQuizModel());
    translatedSummary = widget.summary; // Initialize with the original summary
    summary = widget.summary;
    quizData = widget.quizData;
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _translateSummary() async {
    print(
        "Translation button pressed"); // This should show up in the console when the button is clicked

    // Toggle the view between original and translated text
    if (showTranslated) {
      print("Toggling to show original text");
      setState(() {
        showTranslated = false; // Show original text
      });
      return;
    }

    // If translatedSummary is already set and just needs to be shown
    if (translatedSummary != null && translatedSummary != widget.summary) {
      print("Toggling to show translated text");
      setState(() {
        showTranslated = true; // Show translated text
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
            showTranslated = true; // Toggle to show translated text
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

  void _calculateQuizResult() {
    int correctCount = 0;

    for (int i = 0; i < widget.quizData.length; i++) {
      final correctAnswer = widget.quizData[i]['correctAnswer'];
      if (selectedAnswers.length > i && selectedAnswers[i] == correctAnswer) {
        correctCount++;
      }
    }

    setState(() {
      resultMessage =
          "You answered $correctCount out of ${widget.quizData.length} correctly!";
    });
  }

  List<String?> selectedAnswers = [];
  @override
  Widget build(BuildContext context) {
    topicName = widget.topicName;
    print("Received topic: ${widget.topicName}");
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
          child: SingleChildScrollView(
            // Added to prevent overflow
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
                                alignment:
                                    const AlignmentDirectional(-0.9, -0.9),
                                child: Text(
                                  '${widget.topicName}',
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
                                    alignment:
                                        AlignmentDirectional(-0.9, -0.85),
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
                                    top: 80,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1EEEB),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 600.0,
                                          minHeight: 100.0,
                                          maxHeight: 290.0,
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 1.0, 16.0, 1.0),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            showTranslated
                                                ? translatedSummary ??
                                                    "Translation error"
                                                : widget.summary,
                                            textAlign: TextAlign.start,
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(0.88, -0.76),
                                    child: InkWell(
                                      onTap: _translateSummary,
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
                              height: 384.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF3E1),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25.0),
                                  bottomRight: Radius.circular(25.0),
                                  topLeft: Radius.circular(25.0),
                                  topRight: Radius.circular(25.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                  const Divider(
                                    color: Colors.black26,
                                    thickness: 1.0,
                                  ),
                                  // Render quiz data dynamically
                                  Expanded(
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: quizData?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final question =
                                            quizData![index]['question'];
                                        final options =
                                            quizData![index]['options'];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}. $question',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'DM Sans',
                                                          color: Colors.black,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: (options
                                                        as Map<String, dynamic>)
                                                    .entries
                                                    .map((entry) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Radio<String>(
                                                          value: entry.key,
                                                          groupValue: selectedAnswers
                                                                      .length >
                                                                  index
                                                              ? selectedAnswers[
                                                                  index]
                                                              : null,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              if (selectedAnswers
                                                                      .length <=
                                                                  index) {
                                                                selectedAnswers
                                                                    .add(value);
                                                              } else {
                                                                selectedAnswers[
                                                                        index] =
                                                                    value;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            entry.value,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'DM Sans',
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                            maxLines:
                                                                3, // Optional: Limit the number of lines for answers
                                                            overflow: TextOverflow
                                                                .ellipsis, // Optional: Truncate long text
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        // Add logic to handle quiz submission
                                        print(
                                            'Selected answers: $selectedAnswers');
                                      },
                                      text: 'Submit Quiz',
                                      options: FFButtonOptions(
                                        width: 200.0,
                                        height: 40.0,
                                        color: const Color(0xFF104036),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'DM Sans',
                                              color: Colors.white,
                                            ),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                  alignment: AlignmentDirectional.bottomCenter,
                  child: InkWell(
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
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF104036),
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
      ),
    );
  }
}
