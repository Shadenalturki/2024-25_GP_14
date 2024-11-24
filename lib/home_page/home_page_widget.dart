import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> courses =
      []; // List to store course name and description

  @override
  void initState() {
    super.initState();
    _fetchCoursesFromDatabase();
  }

  /// Fetch courses from Firestore for the current user
  Future<void> _fetchCoursesFromDatabase() async {
    final userId = currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final fetchedCourses = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'courseName': data['courseName'] as String,
          'courseDescription': data['courseDescription'] as String? ?? '',
        };
      }).toList();

      setState(() {
        courses = fetchedCourses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $e')),
      );
    }
  }

  /// Save a course to the Firestore database
  Future<void> _saveCourseToDatabase(
      String courseName, String courseDescription) async {
    final userId = currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    try {
      final newCourse = {
        'courseName': courseName,
        'courseDescription': courseDescription,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('courses').add(newCourse);

      setState(() {
        courses.insert(0,
            {'courseName': courseName, 'courseDescription': courseDescription});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving course: $e')),
      );
    }
  }

  void _showAddCourseDialog() {
    TextEditingController courseNameController = TextEditingController();
    TextEditingController courseDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter course name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: courseDescriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter course description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String courseName = courseNameController.text.trim();
                String courseDescription =
                    courseDescriptionController.text.trim();
                if (courseName.isNotEmpty) {
                  _saveCourseToDatabase(courseName, courseDescription);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Course name cannot be empty.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCourseDialog(int index) {
    TextEditingController courseNameController = TextEditingController(
      text: courses[index]['courseName'],
    );
    TextEditingController courseDescriptionController = TextEditingController(
      text: courses[index]['courseDescription'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  hintText: 'Edit course name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: courseDescriptionController,
                decoration: const InputDecoration(
                  hintText: 'Edit course description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String updatedCourseName = courseNameController.text.trim();
                String updatedCourseDescription =
                    courseDescriptionController.text.trim();

                if (updatedCourseName.isNotEmpty) {
                  final userId = currentUser?.uid;
                  if (userId != null) {
                    try {
                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('courses')
                          .where('userId', isEqualTo: userId)
                          .get();

                      final docId = querySnapshot.docs[index].id;

                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(docId)
                          .update({
                        'courseName': updatedCourseName,
                        'courseDescription': updatedCourseDescription,
                      });

                      setState(() {
                        courses[index]['courseName'] = updatedCourseName;
                        courses[index]['courseDescription'] =
                            updatedCourseDescription;
                      });

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating course: $e'),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Course name cannot be empty.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF104036),
        automaticallyImplyLeading: false,
        title: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/S_logoo.png',
                  fit: BoxFit.fill,
                  alignment: const Alignment(0, 0),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Text(
                  'SummAIze ',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inknut Antiqua',
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        actions: const [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 220,
              child: Stack(
                alignment: const AlignmentDirectional(1, -1),
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1.03, -0.82),
                    child: Container(
                      width: 391,
                      height: 190,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0, -1.16),
                    child: Container(
                      width: 436,
                      height: 133,
                      decoration: BoxDecoration(
                        color: const Color(0xFF104036),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(40),
                        ),
                        border: Border.all(
                          color: const Color(0xFF104036),
                          width: 0,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-0.99, -1.01),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        'assets/images/Rectangle_18819.png',
                        width: 290,
                        height: 217,
                        fit: BoxFit.contain,
                        alignment: const Alignment(-1, -1),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-0.83, 0.14),
                    child: Text(
                      'Enjoy your\nlearning journey! ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'DM Sans',
                            color: const Color(0xFF8F9291),
                            fontSize: 18,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-0.93, -0.44),
                    child: AuthUserStreamWidget(
                      builder: (context) => Text(
                        currentUserDisplayName,
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: Colors.black,
                              fontSize: 30,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-0.83, -0.72),
                    child: Text(
                      'Welcome',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: const Color(0xFF8F9291),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.83, 0.88),
                    child: FFButtonWidget(
                      onPressed: _showAddCourseDialog,
                      text: 'Add Course',
                      icon: const Icon(
                        Icons.add,
                        size: 24,
                      ),
                      options: FFButtonOptions(
                        height: 40,
                        color: const Color(0xFF104036),
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: const Color(0xFFC5CAC6),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      course['courseName']!,
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            fontFamily: 'Outfit',
                                            color: const Color(0xFF14181B),
                                            fontSize: 24.0,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Color(0xFF104036)),
                                    onPressed: () {
                                      _showEditCourseDialog(index);
                                    },
                                  ),
                                ],
                              ),
                              if (course['courseDescription']!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 10.0), // Reduced top padding
                                  child: Text(
                                    course['courseDescription']!,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Outfit',
                                          color: const Color(0xFF8F9291),
                                          fontSize: 16.0,
                                        ),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FFButtonWidget(
                                    onPressed: () async {
                                      context.pushNamed('summaryQuiz');
                                    },
                                    text: 'Upload',
                                    icon: const Icon(Icons.upload_file),
                                    options: FFButtonOptions(
                                      height: 40.0,
                                      color: const Color(0xFF104036),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Inter Tight',
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                  ),
                                  FFButtonWidget(
                                    onPressed: () async {
                                      context.pushNamed('history');
                                    },
                                    text: 'History',
                                    icon: const Icon(Icons.history),
                                    options: FFButtonOptions(
                                      height: 40.0,
                                      color: const Color(0xFF104036),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Inter Tight',
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(25.0),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
