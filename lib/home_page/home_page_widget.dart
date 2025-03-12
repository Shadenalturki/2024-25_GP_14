import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:summ_a_ize/backend/constants.dart';
import 'package:summ_a_ize/summary_quiz/summary_quiz_widget.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

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
          'courseId': doc.id, // Include the courseId
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

  /// Save summary to Firebase
  Future<void> _saveSummaryToFirebase(String courseId, String summary,
      String topicName, List<dynamic> quizData) async {
    try {
      final newDocRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('summaries')
          .doc();

      await newDocRef.set({
        'summaryId': newDocRef.id,
        'summary': summary,
        'topicName': topicName,
        'quizData': quizData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Summary saved for courseId: $courseId, topic: $topicName");

      // ✅ Debug Firestore write for topics
      final topicRef = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .add({
        'topicName': topicName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Topic saved in Firestore with ID: ${topicRef.id}");
    } catch (e) {
      print("❌ Error saving summary and topic: $e");
    }
  }

  Future<void> _saveExtractedMaterialToFirebase(
      String courseId, String extractedText) async {
    try {
      // Save the extracted material in an "extractedMaterials" sub-collection
      await FirebaseFirestore.instance
          .collection('courses') // Main collection for courses
          .doc(courseId) // Document for the specific course
          .collection(
              'extractedMaterials') // Sub-collection for extracted materials
          .add({
        'extractedText': extractedText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Extracted material saved successfully!");
    } catch (e) {
      print("Error saving extracted material: $e");
    }
  }

  /// Save a course to the Firestore database with a unique courseId
  Future<void> _saveCourseToDatabase(
      String courseName, String courseDescription) async {
    final userId = currentUser?.uid;

    if (userId == null) {
      _showErrorDialog('Error', 'User not logged in.');
      return;
    }

    try {
      // Check if a course with the same name already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .where('courseName', isEqualTo: courseName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show error pop-up if a duplicate course is found
        _showErrorDialog(
            'Duplicate Course', 'A course with this name already exists.');
        return;
      }

      // Create a new document reference to get a unique courseId
      final newDocRef = FirebaseFirestore.instance.collection('courses').doc();

      // If no duplicates, proceed to save the course
      final newCourse = {
        'courseId': newDocRef.id, // Unique courseId
        'courseName': courseName,
        'courseDescription': courseDescription,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await newDocRef.set(newCourse);

      // Add the newly created course to the local list with all fields
      setState(() {
        courses.insert(0, {
          'courseId': newDocRef.id, // Include courseId
          'courseName': courseName,
          'courseDescription': courseDescription,
        });
      });

      print("Course added: $newCourse"); // Debugging
    } catch (e) {
      _showErrorDialog('Error', 'Error saving course: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCourseFromDatabase(int index) async {
    final userId = currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    try {
      // Get the courseId for the course to delete
      final courseId = courses[index]['courseId'];

      if (courseId != null) {
        // Step 1: Delete all summaries in the 'summaries' sub-collection
        final summariesQuery = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('summaries')
            .get();

        for (var summaryDoc in summariesQuery.docs) {
          await summaryDoc.reference.delete();
        }

        // Step 2: Delete all extracted materials in the 'extractedMaterials' sub-collection
        final extractedMaterialsQuery = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('extractedMaterials')
            .get();

        for (var materialDoc in extractedMaterialsQuery.docs) {
          await materialDoc.reference.delete();
        }

        // Step 3: Delete all events linked to this course in the 'events' collection
        final eventsQuery = await FirebaseFirestore.instance
            .collection('events')
            .where('courseId', isEqualTo: courseId)
            .get();

        for (var eventDoc in eventsQuery.docs) {
          await eventDoc.reference.delete();
        }

        // Step 4: Delete the course document itself
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .delete();

        // Remove the course from the local list
        setState(() {
          courses.removeAt(index);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting course: $e')),
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
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
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFF4A4A4A), // Dark grey text
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
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
                      // Check if a course with the same name exists (excluding the current one)
                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('courses')
                          .where('userId', isEqualTo: userId)
                          .where('courseName', isEqualTo: updatedCourseName)
                          .get();

                      // Check if duplicate exists and is not the current course
                      bool isDuplicate = querySnapshot.docs.any(
                        (doc) => doc.id != courses[index]['courseId'],
                      );

                      if (isDuplicate) {
                        // Show error pop-up if duplicate found
                        _showErrorDialog('Duplicate Course',
                            'A course with this name already exists. Please use a different name.');
                        return;
                      }

                      // Proceed with updating the course
                      final docId = courses[index]['courseId'];

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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content: const Text('Course name cannot be empty.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFF4A4A4A), // Dark grey text
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String summary = "";
  String formatSummaryText(String summary) {
    // Step 1: Add a line space before each '**'
    String formattedText = summary.replaceAllMapped(RegExp(r'\*\*'), (match) {
      return '\n${match.group(0)}'; // Add a line space before '**'
    });

    // Step 2: Add a line space after each '.'
    formattedText = formattedText.replaceAllMapped(RegExp(r'\.'), (match) {
      return '${match.group(0)}\n'; // Add a line space after '.'
    });

    // Step 3: Remove '**' for bold text, single '*', replace '+' with bullet points
    formattedText = formattedText
        .replaceAll(RegExp(r'\*\*'), '') // Remove double asterisks for bold
        .replaceAll('*', '') // Remove single asterisks
        .replaceAll('+', '•'); // Replace '+' with bullet points

    // Step 4: Ensure all text is aligned to the left
    final lines = formattedText.split('\n'); // Split the text into lines
    final List<String> alignedLines = [];

    for (String line in lines) {
      alignedLines.add(line.trimLeft()); // Trim spaces on the left of each line
    }

    // Join the lines back into a single formatted string
    return alignedLines.join('\n');
  }

  Future<void> _promptForTopicAndUpload(String courseId) async {
    TextEditingController topicController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Topic Name'),
          content: TextField(
            controller: topicController,
            decoration: const InputDecoration(hintText: 'Topic name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                    0xFF4A4A4A), // Set color for "OK" button in error dialog
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                    0xFF4A4A4A), // Set color for "OK" button in error dialog
              ),
              onPressed: () {
                String trimmedTopic = topicController.text.trim();
                if (trimmedTopic.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Topic name cannot be empty."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the error dialog
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(
                                  0xFF4A4A4A), // Set color for "OK" button in error dialog
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.of(context).pop();
                  _checkTopicAndUpload(courseId, trimmedTopic);
                }
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkTopicAndUpload(String courseId, String topicName) async {
    // Query Firestore to see if the topic name already exists for this course
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('summaries')
        .where('topicName', isEqualTo: topicName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If topic name doesn't exist, proceed with the upload
      _uploadFile(courseId, topicName);
    } else {
      // If topic name exists, show an error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "This topic name already exists for this course. Please choose a different name."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the error dialog
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(
                      0xFF4A4A4A), // Set color for "OK" button in error dialog
                ),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  late List quizData = [];
  Future<void> _uploadFile(String courseId, String topicName) async {
    print(
        "Uploading file for courseId: $courseId, Topic: $topicName"); // Debug to check courseId

    // File picker and upload process remains the same
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDF files
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileNameWithExtension = file.path.split('/').last;
      String fileNameWithoutExtension = fileNameWithExtension.split('.').first;
      print('Selected file: $fileNameWithoutExtension');

      final uploadUrl = Uri.parse('${ApiConstant.baseUrl}upload');
      print('Upload URL: $uploadUrl');
      final summarizeUrl = Uri.parse('${ApiConstant.baseUrl}summarize');
      final quizUrl = Uri.parse('${ApiConstant.baseUrl}generate_quiz_all');
      final uploadRequest = http.MultipartRequest('POST', uploadUrl);
      uploadRequest.files
          .add(await http.MultipartFile.fromPath('files', file.path));

      // Show a loading pop-up for file upload
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text("Uploading file..."),
              ],
            ),
          );
        },
      );

      try {
        // Send upload request
        final uploadResponse = await uploadRequest.send();

        // Dismiss the file upload dialog
        Navigator.pop(context);

        if (uploadResponse.statusCode == 200) {
          print('File uploaded successfully...........');
          final responseBody = await uploadResponse.stream.bytesToString();
          final jsonResponse = jsonDecode(responseBody);

          if (jsonResponse.containsKey('extracted_text')) {
            final extractedText = jsonResponse['extracted_text'];
            final sessionPdfId = jsonResponse['session'];
            print("Session PDF ID: $sessionPdfId");

            // Save the extracted text to Firestore
            await _saveExtractedMaterialToFirebase(courseId, extractedText);

            // Show a success pop-up for file upload
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("File Uploaded Successfully ✔️"),
                  content: const Text("The file has been uploaded."),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF4A4A4A), // Dark grey text
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );

            // Show a loading pop-up for summary generation
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text("Generating summary..."),
                    ],
                  ),
                );
              },
            );

            final quizRequest = http.MultipartRequest('POST', quizUrl);
            quizRequest.files
                .add(await http.MultipartFile.fromPath('file', file.path));

            final quizResponse = await quizRequest.send();

            if (quizResponse.statusCode == 200) {
              // Convert the response stream into a string
              final responseBody = await quizResponse.stream.bytesToString();

              // Parse the responseBody into JSON
              final jsonResponse = jsonDecode(responseBody);

              // Access the quiz data directly from the parsed JSON
              quizData = jsonResponse[
                  'quiz']; // Remove .body as jsonResponse is already parsed

              print(
                  "Complete Response: ${jsonEncode(jsonResponse)}"); // Debugging
              print("Quiz Data: $quizData"); // Debugging to verify quiz content
            } else {
              print(
                  "Failed to fetch quiz. Status code: ${quizResponse.statusCode}");
            }

            // Call the summarize endpoint
            final summarizeResponse = await http.post(
              summarizeUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'text': extractedText}),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => QuizWidget(
            //       quizData: quizData,
            //       topicName: topicName,
            //     ),
            //   ),
            // );
            // Dismiss the summary generation dialog
            Navigator.pop(context);

            if (summarizeResponse.statusCode == 200) {
              final summaryJson = jsonDecode(summarizeResponse.body);

              if (summaryJson.containsKey('summary')) {
                final summary = summaryJson['summary'];
                String formattedSummary = formatSummaryText(summary);
                print("Quiz Data Before Saving: $quizData");

                // Save the summary to Firebase
                await _saveSummaryToFirebase(
                    courseId, formattedSummary, topicName, quizData);

                // Navigate to the summary screen with formatted text
                print("sessionPdfId during navigatio: $sessionPdfId");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryQuizWidget(
                        summary: formattedSummary,
                        topicName: fileNameWithoutExtension,
                        quizData: quizData,
                        sessionPdfId: sessionPdfId),
                  ),
                );
              } else {
                // Show error pop-up if summary not found
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Error"),
                      content: const Text("No summary found in response."),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF4A4A4A), // Dark grey text
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              }
            } else {
              // Show error pop-up if summarization fails
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: Text(
                        "Failed to summarize text. Status code: ${summarizeResponse.statusCode}"),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF4A4A4A), // Dark grey text
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            // Show error pop-up if extracted text not found
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: const Text("No extracted text found in response."),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF4A4A4A), // Dark grey text
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // Show error pop-up if upload fails
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(
                    "Failed to upload file. Status code: ${uploadResponse.statusCode}"),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF4A4A4A), // Dark grey text
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        // Dismiss the file upload dialog in case of an error
        Navigator.pop(context);

        // Show error pop-up
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text("Error uploading file: $e"),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show error pop-up if no file selected or unsupported format
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("No file selected or unsupported format."),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A4A4A), // Dark grey text
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
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
            SizedBox(
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
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Color(0xFF104036)),
                                        onPressed: () {
                                          _showEditCourseDialog(index);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Color(0xFF104036)),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Delete Course'),
                                                content: const Text(
                                                    'Are you sure you want to delete this course?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                    ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                    ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmed == true) {
                                            await _deleteCourseFromDatabase(
                                                index);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (course['courseDescription']!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0, bottom: 10.0),
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
                                    onPressed: () {
                                      final courseId = course['courseId'];
                                      print(
                                          "courseId: $courseId"); // Debug to check if it is null or empty

                                      if (courseId != null) {
                                        _promptForTopicAndUpload(courseId);
                                        //_uploadFile(courseId);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Error: Course ID not found'),
                                          ),
                                        );
                                      }
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
                                      final courseId = course[
                                          'courseId']; // Retrieve courseId
                                      if (courseId != null) {
                                        context.pushNamed(
                                          'history',
                                          queryParameters: {
                                            'courseId': courseId
                                          }, // Pass courseId as a query parameter
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Error: Course ID not found')),
                                        );
                                      }
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
