import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:summ_a_ize/summary_quiz/summary_quiz_widget.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistoryWidget extends StatefulWidget {
  final String courseId;

  const HistoryWidget({super.key, required this.courseId});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  Future<void> _navigateToSummaryQuiz(String topicName) async {
    try {
      // Fetch the summary and quiz data from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('summaries')
          .where('topicName', isEqualTo: topicName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final summaryData = querySnapshot.docs.first.data();
        final summary = summaryData['summary'] ?? 'No summary available';
        final quizData = summaryData['quizData'] ?? [];

        print("Quiz Data:----1       $quizData");

        // Navigate to SummaryQuizWidget with fetched data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryQuizWidget(
              summary: summary,
              topicName: topicName,
              quizData: quizData,
            ),
          ),
        );

        // context.pushNamed(
        //   'summaryQuiz',
        //   queryParameters: {
        //     'summary': summary,
        //     'topicName': topicName,
        //   },
        //   extra: {
        //     'quizData': quizData,
        //   },
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No summary found for this topic.')),
        );
      }
    } catch (e) {
      print('❌ Error fetching summary and quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load summary and quiz data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF104036),
        title: Text(
          'History',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inknut Antiqua',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: FlutterFlowIconButton(
          borderRadius: 30,
          buttonSize: 60,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('topics')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No topics found.'));
          }

          final topics = snapshot.data!.docs;

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topicData = topics[index].data() as Map<String, dynamic>;
              final topicName = topicData['topicName'];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _navigateToSummaryQuiz(topicName),
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC5CAC6)),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        topicName,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
