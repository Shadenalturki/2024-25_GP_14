import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'quiz_model.dart';
export 'quiz_model.dart';

class QuizWidget extends StatefulWidget {
  final String topicName;
  final List<dynamic> quizData; // Accept quiz data
  const QuizWidget({Key? key, required this.quizData,required this.topicName,}) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  late String topicName;
  late QuizModel _model; // For QuizModel
  late List<dynamic> quizData; // Store quiz data
  late Map<int, String?> selectedAnswers; // Store user-selected answers

  final scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold key

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizModel()); // Initialize QuizModel
    quizData = widget.quizData; // Initialize with passed data
    selectedAnswers = {}; // Initialize with empty selected answers
    topicName = widget.topicName;
  }

  @override
  void dispose() {
    _model.dispose(); // Dispose QuizModel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Topic Name: ${widget.topicName}"); // Debugging
    print('quizData: ${widget.quizData}');
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
              context.pushNamed('HomePage');
            },
          ),
          title: Text(
            'SummAIze Notebook',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inknut Antiqua',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
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
                                // Quiz Section
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    width: 352.0,
                    constraints: const BoxConstraints(
                      maxHeight: 600.0,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0),
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-0.9, -0.54),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 5.0, 0.0, 0.0),
                              child: Text(
                                'Quiz',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'DM Sans',
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          // Dynamically Render Quiz Questions
                          for (int i = 0; i < widget.quizData.length; i++) ...[
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    6.0, 10.0, 0.0, 0.0),
                                child: Text(
                                  'Question #${i + 1}: ${widget.quizData[i]['question']}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: const Color(0xFF070707),
                                      ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: FlutterFlowRadioButton(
                                options: widget.quizData[i]['options'].values
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedAnswers[i] =
                                        val; // Save user's answer
                                  });
                                },
                                controller: FormFieldController<String>(null),
                                optionHeight: 23.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                selectedTextStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                buttonPosition: RadioButtonPosition.left,
                                direction: Axis.vertical,
                                radioButtonColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ],
                          // Submit Button
                          FFButtonWidget(
                            onPressed: () {
                              int score = 0;
                              for (int i = 0; i < widget.quizData.length; i++) {
                                final correctAnswer =
                                    widget.quizData[i]['correct'];
                                final userAnswer = selectedAnswers[i];
                                if (userAnswer == correctAnswer) {
                                  score++;
                                }
                              }
                              // Show score in a dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Quiz Completed'),
                                  content: Text(
                                      'Your score: $score/${widget.quizData.length}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            text: 'Submit',
                            options: FFButtonOptions(
                              width: 100.0,
                              height: 40.0,
                              color: const Color(0xFF104036),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                  ),
                              borderRadius: BorderRadius.circular(8.0),
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
                      ].divide(const SizedBox(height: 8.0)),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.85, 0.97),
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
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
          /*child: SingleChildScrollView(
            child: Column(
              children: [
                
                // Quiz Section
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    width: 352.0,
                    constraints: const BoxConstraints(
                      maxHeight: 600.0,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0),
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-0.9, -0.54),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 5.0, 0.0, 0.0),
                              child: Text(
                                'Quiz',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'DM Sans',
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          // Dynamically Render Quiz Questions
                          for (int i = 0; i < widget.quizData.length; i++) ...[
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    6.0, 10.0, 0.0, 0.0),
                                child: Text(
                                  'Question #${i + 1}: ${widget.quizData[i]['question']}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: const Color(0xFF070707),
                                      ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: FlutterFlowRadioButton(
                                options: widget.quizData[i]['options'].values
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedAnswers[i] =
                                        val; // Save user's answer
                                  });
                                },
                                controller: FormFieldController<String>(null),
                                optionHeight: 23.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                selectedTextStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                buttonPosition: RadioButtonPosition.left,
                                direction: Axis.vertical,
                                radioButtonColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ],
                          // Submit Button
                          FFButtonWidget(
                            onPressed: () {
                              int score = 0;
                              for (int i = 0; i < widget.quizData.length; i++) {
                                final correctAnswer =
                                    widget.quizData[i]['correct'];
                                final userAnswer = selectedAnswers[i];
                                if (userAnswer == correctAnswer) {
                                  score++;
                                }
                              }
                              // Show score in a dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Quiz Completed'),
                                  content: Text(
                                      'Your score: $score/${widget.quizData.length}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            text: 'Submit',
                            options: FFButtonOptions(
                              width: 100.0,
                              height: 40.0,
                              color: const Color(0xFF104036),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                  ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tutor Bot Section
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
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
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
          ),*/
        ),
      ),
    );
  }
}
