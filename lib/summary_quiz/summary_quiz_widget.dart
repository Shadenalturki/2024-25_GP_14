import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http; // Add this line for HTTP requests
import 'package:summ_a_ize/chatbot/chatbot_widget.dart';
import 'package:summ_a_ize/flutter_flow/flutter_flow_widgets.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'summary_quiz_model.dart';

export 'summary_quiz_model.dart';

class SummaryQuizWidget extends StatefulWidget {
  final String summary;
  final String topicName;
  final List quizData;
  final String? sessionPdfId;

  const SummaryQuizWidget({
    required this.summary,
    required this.topicName,
    required this.quizData,
    this.sessionPdfId,
    super.key,
  });

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
    print("Summary: ${widget.summary}");
    translatedSummary = widget.summary; // Initialize with the original summary
    summary = widget.summary;
    quizData = widget.quizData;
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> translateSummary() async {
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

    setState(() {
      isTranslating = true; // Set translating state to true
    });
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
            print(
                "Translated summary: ${responseData['translated_summary']} ${widget.summary}}, $translatedSummary");
            showTranslated = true;
            isTranslating = false; // Toggle to show translated text
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
        isTranslating = false;
      });
    }
  }

  bool _isArabic(String text) {
    // Regular expression to match Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  bool showCorrectAnswers = false;
  bool isTranslating = false;
  bool showQuiz = false;

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
        floatingActionButton: InkWell(
          onTap: () async {
            // context.pushNamed('chatbot');
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ChatbotWidget(
                sessionPdfId: widget.sessionPdfId,
              );
            }));
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
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: const Color(0xFF104036),
                      ),
                ),
              ],
            ),
          ),
        ),
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
                                  widget.topicName,
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
                                        const AlignmentDirectional(-0.9, -0.85),
                                    child: Text(
                                      'Summary',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'DM Sans',
                                            color: const Color(0xFF202325),
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
                                          child: isTranslating
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : Text(
                                                  showTranslated
                                                      ? translatedSummary ??
                                                          "Translation error"
                                                      : widget.summary,
                                                  textAlign: TextAlign.start,
                                                  textDirection: _isArabic(
                                                          showTranslated
                                                              ? translatedSummary ??
                                                                  ""
                                                              : widget.summary)
                                                      ? painting
                                                          .TextDirection.rtl
                                                      : painting
                                                          .TextDirection.ltr,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                      onTap: translateSummary,
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
                          Visibility(
                            visible: showQuiz,
                            child: Align(
                              alignment: const AlignmentDirectional(0.0, 0.5),
                              child: Container(
                                width: 352.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF3E1),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(25.0),
                                    bottomRight: Radius.circular(25.0),
                                    topLeft: Radius.circular(25.0),
                                    topRight: Radius.circular(25.0),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
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
                                      ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: quizData?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          final question =
                                              quizData![index]['question'];
                                          final options = quizData![index]
                                                  ['options']
                                              as Map<String, dynamic>;
                                          final correctAnswer = quizData![index]
                                                  ['correct']
                                              .toString()
                                              .split(')')[0]
                                              .toLowerCase()
                                              .trim();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${index + 1}. $question',
                                                  style: FlutterFlowTheme.of(
                                                          context)
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
                                                  children: options.entries
                                                      .map((entry) {
                                                    // Check if this option is the correct answer
                                                    bool isCorrectAnswer = entry
                                                            .key
                                                            .toLowerCase() ==
                                                        correctAnswer;

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 4.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Radio<String>(
                                                            value: entry.key,
                                                            groupValue: selectedAnswers
                                                                        .length >
                                                                    index
                                                                ? selectedAnswers[
                                                                    index]
                                                                : null,
                                                            onChanged:
                                                                showCorrectAnswers
                                                                    ? null
                                                                    : (value) {
                                                                        setState(
                                                                            () {
                                                                          if (selectedAnswers.length <=
                                                                              index) {
                                                                            selectedAnswers.add(value);
                                                                          } else {
                                                                            selectedAnswers[index] =
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
                                                                    fontFamily:
                                                                        'DM Sans',
                                                                    fontSize:
                                                                        14.0,
                                                                    color: showCorrectAnswers &&
                                                                            isCorrectAnswer
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight: showCorrectAnswers &&
                                                                            isCorrectAnswer
                                                                        ? FontWeight
                                                                            .bold
                                                                        : FontWeight
                                                                            .normal,
                                                                  ),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0),
                                        child: FFButtonWidget(
                                          onPressed: () {
                                            // Debug print to check selected answers and correct answers
                                            print(
                                                'Selected answers: $selectedAnswers');
                                            print('Quiz data: $quizData');

                                            int correctCount = 0;
                                            int incorrectCount = 0;

                                            if (selectedAnswers.length ==
                                                quizData!.length) {
                                              for (int i = 0;
                                                  i < quizData!.length;
                                                  i++) {
                                                // Extract just the letter from the correct answer (before the first ')')
                                                String correctAnswer =
                                                    quizData![i]['correct']
                                                        .toString()
                                                        .split(')')[0]
                                                        .toLowerCase()
                                                        .trim();

                                                if (selectedAnswers.length >
                                                        i &&
                                                    selectedAnswers[i] !=
                                                        null) {
                                                  // Debug prints to verify the comparison
                                                  print('Question ${i + 1}:');
                                                  print(
                                                      'Selected answer: ${selectedAnswers[i]!.toLowerCase()}');
                                                  print(
                                                      'Correct answer: $correctAnswer');

                                                  if (selectedAnswers[i]!
                                                          .toLowerCase() ==
                                                      correctAnswer) {
                                                    correctCount++;
                                                    print('✓ Correct!');
                                                  } else {
                                                    incorrectCount++;
                                                    print('✗ Incorrect');
                                                  }
                                                } else {
                                                  incorrectCount++; // Count unanswered questions as incorrect
                                                  print(
                                                      'Question ${i + 1}: No answer selected');
                                                }
                                              }

                                              // Debug print final counts
                                              print(
                                                  'Final correct count: $correctCount');
                                              print(
                                                  'Final incorrect count: $incorrectCount');

                                              setState(() {
                                                showCorrectAnswers =
                                                    true; // Add this line to trigger showing correct answers
                                              });

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Quiz Results',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleLarge
                                                          .override(
                                                            fontFamily:
                                                                'DM Sans',
                                                            color: const Color(
                                                                0xFF104036),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Correct Answers: $correctCount',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'DM Sans',
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Incorrect Answers: $incorrectCount',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'DM Sans',
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Text(
                                                          'Score: ${((correctCount / quizData!.length) * 100).toStringAsFixed(1)}%',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'DM Sans',
                                                                color: const Color(
                                                                    0xFF104036),
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text(
                                                          'Close',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .labelLarge
                                                              .override(
                                                                fontFamily:
                                                                    'DM Sans',
                                                                color: const Color(
                                                                    0xFF104036),
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFFAFAFC),
                                                  );
                                                },
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Please select an answer for all questions.",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            }
                                          },
                                          text: 'Submit Quiz',
                                          options: FFButtonOptions(
                                            width: 200.0,
                                            height: 40.0,
                                            color: const Color(0xFF104036),
                                            textStyle:
                                                FlutterFlowTheme.of(context)
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
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  showQuiz =
                                      !showQuiz; // Toggle quiz visibility
                                });
                              },
                              text: showQuiz
                                  ? 'Hide Quiz'
                                  : 'Show Quiz', // Change button text based on state
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
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 8.0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
