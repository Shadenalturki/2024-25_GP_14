import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'calendar_model.dart';
export 'calendar_model.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for event inputs
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  // Track if a manual date selection was made
  bool hasManuallySelectedDate = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarModel());

    // Fetch events from Firestore when the page loads
    _model.fetchEvents();
  }

  @override
  void dispose() {
    _model.dispose();
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addEvent(DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    if (user == null) {
      // Handle the case where the user is not logged in
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('You must be logged in to add events.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventTitleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: eventDescriptionController,
                decoration:
                    InputDecoration(labelText: 'Event Description (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (eventTitleController.text.trim().isEmpty) {
                  // Show a popup if the event title is empty
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Input'),
                        content: Text('Event name cannot be empty.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Add event to Firestore
                await _model.addEvent(
                  user.uid, // Pass the actual userId from FirebaseAuth
                  eventTitleController.text.trim(), // Trim the title
                  eventDescriptionController.text.trim(), // Trim the description
                  selectedDate,
                );
                eventTitleController.clear(); // Clear title input
                eventDescriptionController.clear(); // Clear description input
                Navigator.of(context).pop(); // Close the Add Event dialog

                // Fetch updated events after adding a new one
                await _model.fetchEvents();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the Add Event dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final veryLightGrey = Color(0xFFF5F5F5); // Very light grey color
    final mediumGreen = Color(0xFF7B9076); // Medium green color

    return ChangeNotifierProvider.value(
      value: _model,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          appBar: AppBar(
            backgroundColor: Color(0xFF104036),
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/S_logoo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Text(
                    'SummAIze ',
                    textAlign: TextAlign.center,
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
            actions: [],
            centerTitle: false,
            elevation: 2,
          ),
          body: Consumer<CalendarModel>(
            builder: (context, model, child) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar view
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: FlutterFlowCalendar(
                      color: FlutterFlowTheme.of(context).primary,
                      weekFormat: false,
                      weekStartsMonday: true,
                      onChange: (DateTimeRange? newSelectedDate) {
                        if (newSelectedDate != null &&
                            hasManuallySelectedDate) {
                          _addEvent(newSelectedDate.start);
                        }
                        hasManuallySelectedDate = true;
                      },
                    ),
                  ),
                  // "Coming Up" Section with unified background
                  Expanded(
                    child: Container(
                      color: veryLightGrey, // Unified background for the section
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Coming Up" Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            child: Text(
                              'Coming Up',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    color: mediumGreen,
                                  ),
                            ),
                          ),
                          // Event List
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: model.upcomingEvents.length,
                              itemBuilder: (context, index) {
                                final event = model.upcomingEvents[index];
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 8, 16, 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Card background
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: mediumGreen, // Medium green border
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['eventName'],
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  fontFamily: 'Inter Tight',
                                                  fontWeight: FontWeight.bold,
                                                  color: mediumGreen,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            DateFormat('EEE, MMM d, yyyy')
                                                .format(event['eventDate']),
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: mediumGreen,
                                                ),
                                          ),
                                        ],
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
