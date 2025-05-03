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
        content: const Text('Are you sure you want to delete this topic?'),
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

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('topics')
          .doc(topicId)
          .update({'isDeleted': true});
    } catch (e) {
      print('❌ Error deleting topic: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete topic.')),
      );
    }
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '') // Remove all spaces
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .trim();
  }

  Future<void> _editTopic(
      BuildContext context, String topicId, String currentName) async {
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Topic'),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Enter new topic name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final rawInput = controller.text.trim();
                    final newName = rawInput;
                    final normalizedNewName = _normalize(rawInput);

                    if (normalizedNewName.isEmpty) return;

                    try {
                      final topicsSnapshot = await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(widget.courseId)
                          .collection('topics')
                          .get();

                      final existingNames = topicsSnapshot.docs
                          .where((doc) => doc.id != topicId)
                          .map((doc) =>
                              _normalize(doc.data()['topicName'] as String))
                          .toList();

                      if (existingNames.contains(normalizedNewName)) {
                        // ❗ Close Edit Dialog First
                        Navigator.of(context).pop();

                        // ❗ Then open confirmation dialog
                        final proceed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Similar Topic Found'),
                            content: const Text(
                              'A topic with a similar name already exists. Do you still want to update it?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                                child: const Text('Update Anyway'),
                              ),
                            ],
                          ),
                        );

                        if (proceed != true) return; // User cancelled
                      } else {
                        // No duplicate → close Edit Dialog manually
                        Navigator.of(context).pop();
                      }

                      // Now update Firestore
                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(widget.courseId)
                          .collection('topics')
                          .doc(topicId)
                          .update({'topicName': newName});

                      // Update summaries
                      final summaries = await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(widget.courseId)
                          .collection('summaries')
                          .where('topicName', isEqualTo: currentName)
                          .get();

                      for (var doc in summaries.docs) {
                        await doc.reference.update({'topicName': newName});
                      }
                    } catch (e) {
                      print('❌ Error updating topic: $e');
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Failed to update topic.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _permanentlyDeleteTopic(String topicId, String topicName) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('topics')
          .doc(topicId)
          .delete();

      final summaries = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('summaries')
          .where('topicName', isEqualTo: topicName)
          .get();

      for (var doc in summaries.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('❌ Permanent deletion error: $e');
    }
  }

  Future<void> _recoverTopic(String topicId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('topics')
        .doc(topicId)
        .update({'isDeleted': false});
  }

  Future<void> _navigateToSummaryQuiz(String topicId, String topicName) async {
    try {
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
        final sessionPdfId = summaryData['sessionPdfId']; // optional
        final chatTopicId = summaryData['chatTopicId']; // ✅ pull it

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryQuizWidget(
              summary: summary,
              topicName: topicName,
              quizData: quizData,
              sessionPdfId: sessionPdfId,
              topicId: chatTopicId, // ✅ keep this one
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No summary found for this topic.')),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
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

          final allTopics = snapshot.data!.docs;

          final activeTopics = allTopics
              .where((doc) =>
                  !((doc.data() as Map<String, dynamic>)['isDeleted'] ?? false))
              .toList();

          final deletedTopics = allTopics
              .where((doc) =>
                  ((doc.data() as Map<String, dynamic>)['isDeleted'] ?? false))
              .toList();

          final topics = [
            ...activeTopics,
            ...deletedTopics
          ]; // active first, then deleted

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topicDoc = topics[index];
              final topicId = topicDoc.id; // Firestore document ID ✅
              final topicData = topicDoc.data() as Map<String, dynamic>;
              final topicName = topicData['topicName'];

              final isDeleted = topicData['isDeleted'] ?? false;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: ListTile(
                    onTap: isDeleted
                        ? null
                        : () => _navigateToSummaryQuiz(topicId, topicName),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    tileColor:
                        isDeleted ? Colors.grey[300] : const Color(0xFFFDFDFD),
                    title: Text(
                      topicName,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: isDeleted ? Colors.grey[700] : Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: isDeleted
                          ? [
                              IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Color(0xFF104036)),
                                onPressed: () => _recoverTopic(topicId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Permanently Delete Topic'),
                                      content: const Text(
                                        'This will permanently delete the topic and its summary. This action cannot be undone. Are you sure?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _permanentlyDeleteTopic(
                                        topicId, topicName);
                                  }
                                },
                              ),
                            ]
                          : [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF104036)),
                                onPressed: () =>
                                    _editTopic(context, topicId, topicName),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color(0xFFB00020)),
                                onPressed: () => _deleteTopic(topicId),
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
