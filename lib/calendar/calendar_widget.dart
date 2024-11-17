import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'calendar_model.dart';
export 'calendar_model.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with TickerProviderStateMixin {
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

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

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
              decoration: InputDecoration(labelText: 'Event Description(optional)'),
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
                  Align(
                    alignment: Alignment(0, 0),
                    child: FlutterFlowButtonTabBar(
                      useToggleButtonStyle: true,
                      isScrollable: true,
                      labelStyle: FlutterFlowTheme.of(context)
                          .titleMedium
                          .override(
                            fontFamily: 'Inter Tight',
                            letterSpacing: 0.0,
                          ),
                      unselectedLabelStyle: TextStyle(),
                      labelColor: FlutterFlowTheme.of(context).secondaryText,
                      unselectedLabelColor:
                          FlutterFlowTheme.of(context).secondaryText,
                      backgroundColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      unselectedBackgroundColor:
                          FlutterFlowTheme.of(context).primaryBackground,
                      borderColor: FlutterFlowTheme.of(context).alternate,
                      borderWidth: 2,
                      borderRadius: 12,
                      elevation: 0,
                      labelPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                      tabs: [
                        Tab(
                          text: 'Month',
                        ),
                        Tab(
                          text: 'Week',
                        ),
                      ],
                      controller: _model.tabBarController,
                      onTap: (i) async {
                        [() async {}, () async {}][i]();
                      },
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _model.tabBarController,
                      children: [
                        // Month View
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
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
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 12, 0, 0),
                                  child: Text(
                                    'Coming Up',
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: model.upcomingEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = model.upcomingEvents[index];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16, 8, 16, 8),
                                      child: ListTile(
                                        title: Text(event['eventName']),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(event['eventDetails']),
                                            Text(DateFormat('EEE, MMM d, yyyy')
                                                .format(event['eventDate'])),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Week View Placeholder
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                          ),
                          child: Center(
                            child: Text(
                              'Week View Placeholder',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ),
                        ),
                      ],
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


