import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'calendar_widget.dart' show CalendarWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CalendarModel extends FlutterFlowModel<CalendarWidget> with ChangeNotifier {
  /// State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for Calendar widget.
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
Future<void> addEvent(String userId, String title, String description, DateTime eventDate) async {
  try {
    // Add the event to Firestore
    await FirebaseFirestore.instance.collection('events').add({
      'userId': userId,
      'eventName': title,
      'eventDetails': description,
      'eventDate': Timestamp.fromDate(eventDate), // Convert DateTime to Firestore Timestamp
    });

    // Refresh the list of events after adding the new event
    await fetchEvents();
  } catch (e) {
    print('Error adding event to Firestore: $e');
  }
}


  // Function to add an event to Firestore
Future<void> fetchEvents() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is logged in.');
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: user.uid)
        .get();

    events = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'eventName': data['eventName'],
        'eventDetails': data['eventDetails'],
        'eventDate': data['eventDate'] is Timestamp
            ? (data['eventDate'] as Timestamp).toDate()
            : DateTime.parse(data['eventDate'] as String),
      };
    }).toList();

    // Extract unique dates for highlighting
    markedDates = events
        .map((event) {
          final eventDate = event['eventDate'] as DateTime;
          return DateTime(eventDate.year, eventDate.month, eventDate.day); // Only the date
        })
        .toSet()
        .toList();

    notifyListeners();
  } catch (e) {
    print('Error fetching events from Firestore: $e');
  }
}


  /// Static utility function to handle Timestamp or DateTime conversion.
  static DateTime convertToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else {
      throw ArgumentError('Invalid type for date conversion: ${value.runtimeType}');
    }
  }
  // Getter to retrieve events for display
  List<Map<String, dynamic>> get upcomingEvents => events;
}


