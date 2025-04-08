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
Future<void> _deleteTopic(String topicId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Topic'),
      content: const Text('Are you sure you want to delete this topic and its summary?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true) return; // User cancelled

  try {
    // 1. Get topic name first
    final topicDoc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(topicId)
        .get();

    final topicName = topicDoc.data()?['topicName'];

    // 2. Delete the topic
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(topicId)
        .delete();

    // 3. Delete related summary
    final summaries = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('summaries')
        .where('topicName', isEqualTo: topicName)
        .get();

    for (var doc in summaries.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Topic deleted successfully.')),
    );
  } catch (e) {
    print('❌ Error deleting topic: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete topic.')),
    );
  }
}



Future<void> _editTopic(BuildContext context, String topicId, String currentName) async {
  final controller = TextEditingController(text: currentName);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Topic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new topic name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  // 1. Update the topic name in topics collection
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('topics')
                      .doc(topicId)
                      .update({'topicName': newName});

                  // 2. Update it in the summaries collection as well
                  final summaries = await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('summaries')
                      .where('topicName', isEqualTo: currentName)
                      .get();

                  for (var doc in summaries.docs) {
                    await doc.reference.update({'topicName': newName});
                  }

                  Navigator.pop(context);

                
                } catch (e) {
                  print('❌ Error updating topic: $e');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update topic.')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


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
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  child: Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(20),
    child: ListTile(
      onTap: () => _navigateToSummaryQuiz(topicName),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: const Color(0xFFFDFDFD),
      title: Text(
        topicName,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Inter',
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF104036)),
            onPressed: () => _editTopic(context, topics[index].id, topicName),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFB00020)),
            onPressed: () => _deleteTopic(topics[index].id),
          ),
        ],
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
