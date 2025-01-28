import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'calendar_widget.dart' show CalendarWidget;
import 'package:flutter/material.dart';

class CalendarModel extends FlutterFlowModel<CalendarWidget> with ChangeNotifier {
  // State fields for stateful widgets in this page.
  TabController? tabBarController;
  DateTimeRange? calendarSelectedDay1;
  DateTimeRange? calendarSelectedDay2;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local list to temporarily store events fetched from Firestore
  List<Map<String, dynamic>> events = [];
  List<DateTime> markedDates = []; // Store dates with events

  @override
  void initState(BuildContext context) {
    calendarSelectedDay1 = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
    calendarSelectedDay2 = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );

    // Fetch events from Firestore when the model initializes
    fetchEvents();
  }

  @override
  void dispose() {
    tabBarController?.dispose();
  }

  // Function to add an event to Firestore
Future<void> fetchEvents() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is logged in.');
      return;
    }

    final eventsQuerySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: user.uid)
        .get();

    events = await Future.wait(eventsQuerySnapshot.docs.map((doc) async {
      final data = doc.data();
      String? courseName;

      // Fetch courseName properly
      if (data['courseId'] != null && data['courseId'] != '') {
        final courseSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(data['courseId'])
            .get();

        if (courseSnapshot.exists) {
          courseName = courseSnapshot['courseName'];
        }
      }

      return {
        'id': doc.id,
        'eventName': data['eventName'],
        'eventDetails': data['eventDetails'],
        'eventDate': data['eventDate'] is Timestamp
            ? (data['eventDate'] as Timestamp).toDate()
            : DateTime.parse(data['eventDate'] as String),
        'courseId': data['courseId'],  // Ensure courseId is stored
        'courseName': courseName, // Now courseName is properly fetched
      };
    }).toList());

    events.sort((a, b) => (a['eventDate'] as DateTime).compareTo(b['eventDate'] as DateTime));

    // Mark dates with events
    markedDates = events
        .map((event) {
          final eventDate = event['eventDate'] as DateTime;
          return DateTime(eventDate.year, eventDate.month, eventDate.day);
        })
        .toSet()
        .toList();

    notifyListeners();
  } catch (e) {
    print('Error fetching events from Firestore: $e');
  }
}



  // Function to delete an event from Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      // Delete the event from Firestore
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

      // Refresh the list of events after deleting
      await fetchEvents();
    } catch (e) {
      print('Error deleting event from Firestore: $e');
    }
  }

  // Static utility function to handle Timestamp or DateTime conversion.
  static DateTime convertToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else {
      throw ArgumentError('Invalid type for date conversion: ${value.runtimeType}');
    }
  }

  

    // Getter to retrieve "Coming Up" events (events in the future)
  List<Map<String, dynamic>> get upcomingEvents {
    final now = DateTime.now();
    return events.where((event) {
      final eventDate = event['eventDate'] as DateTime;
      return eventDate.isAfter(now); // Filter events with future dates
    }).toList();
  }

  // Getter to retrieve "Passed" events (events in the past)
  List<Map<String, dynamic>> get passedEvents {
    final now = DateTime.now();
    return events.where((event) {
      final eventDate = event['eventDate'] as DateTime;
      return eventDate.isBefore(now); // Filter events with past dates
    }).toList();
  }
}
