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
  Future<void> addEvent(
      String userId, String title, String description, DateTime date) async {
    try {
      await _firestore.collection('events').add({
        'userId': userId, // Link event to the specific user
        'eventName': title,
        'eventDetails': description,
        'eventDate': date, // Store as DateTime
      });
      fetchEvents(); // Refresh local events after adding
    } catch (e) {
      print('Error adding event to Firestore: $e');
    }
  }

  // Function to fetch events from Firestore
  Future<void> fetchEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // Get the current user

      if (user == null) {
        print('No user is logged in.');
        return; // Stop execution if no user is logged in
      }

      final querySnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: user.uid) // Filter by userId
          .get();

      events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'],
          'eventName': data['eventName'],
          'eventDetails': data['eventDetails'],
          'eventDate': data['eventDate'] is Timestamp
              ? (data['eventDate'] as Timestamp).toDate() // Convert Timestamp to DateTime
              : DateTime.parse(data['eventDate'] as String), // Parse String to DateTime
        };
      }).toList();

      // Sort the events by date (soonest first)
      events.sort((a, b) => a['eventDate'].compareTo(b['eventDate']));

      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error fetching events from Firestore: $e');
    }
  }

  // Getter to retrieve events for display
  List<Map<String, dynamic>> get upcomingEvents => events;
}


