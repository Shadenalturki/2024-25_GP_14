import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'history_model.dart';
export 'history_model.dart';

class HistoryWidget extends StatefulWidget {
  final String courseId; // Accept courseId to fetch topics
  const HistoryWidget({Key? key, required this.courseId}) : super(key: key);

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF104036),
        title: Text(
          'History',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inknut Antiqua',
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
          onPressed: () async {
            context.pop();
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
    .collection('courses')
    .doc(widget.courseId)
    .collection('topics')
    .orderBy('createdAt', descending: true)
    .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (data, _) => data,
    )
    .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No topics found.",
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            }

            final topics = snapshot.data!.docs;

            return ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topicData = topics[index].data() as Map<String, dynamic>;
                final topicName = topicData['topicName'];

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Material(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigate to summary page for this topic
                        context.pushNamed(
                          'summaryQuiz',
                          queryParameters: {
                            'topicName': topicName, // Pass topic name
                          },
                        );
                      },
                      child: Container(
                        width: 364,
                        height: 82,
                        decoration: BoxDecoration(
                          color: Color(0xFFFDFDFD),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFC5CAC6), width: 1),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                            child: Text(
                              topicName,
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
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
      ),
    );
  }
}
