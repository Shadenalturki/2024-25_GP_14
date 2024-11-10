import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EventsRecord extends FirestoreRecord {
  EventsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "eventName" field.
  String? _eventName;
  String get eventName => _eventName ?? '';
  bool hasEventName() => _eventName != null;

  // "eventDate" field.
  DateTime? _eventDate;
  DateTime? get eventDate => _eventDate;
  bool hasEventDate() => _eventDate != null;

  // "eventDetails" field.
  String? _eventDetails;
  String get eventDetails => _eventDetails ?? '';
  bool hasEventDetails() => _eventDetails != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  void _initializeFields() {
    _eventName = snapshotData['eventName'] as String?;
    _eventDate = snapshotData['eventDate'] as DateTime?;
    _eventDetails = snapshotData['eventDetails'] as String?;
    _userId = snapshotData['userId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('events');

  static Stream<EventsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EventsRecord.fromSnapshot(s));

  static Future<EventsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EventsRecord.fromSnapshot(s));

  static EventsRecord fromSnapshot(DocumentSnapshot snapshot) => EventsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EventsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EventsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EventsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EventsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEventsRecordData({
  String? eventName,
  DateTime? eventDate,
  String? eventDetails,
  String? userId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'eventName': eventName,
      'eventDate': eventDate,
      'eventDetails': eventDetails,
      'userId': userId,
    }.withoutNulls,
  );

  return firestoreData;
}

class EventsRecordDocumentEquality implements Equality<EventsRecord> {
  const EventsRecordDocumentEquality();

  @override
  bool equals(EventsRecord? e1, EventsRecord? e2) {
    return e1?.eventName == e2?.eventName &&
        e1?.eventDate == e2?.eventDate &&
        e1?.eventDetails == e2?.eventDetails &&
        e1?.userId == e2?.userId;
  }

  @override
  int hash(EventsRecord? e) => const ListEquality()
      .hash([e?.eventName, e?.eventDate, e?.eventDetails, e?.userId]);

  @override
  bool isValidKey(Object? o) => o is EventsRecord;
}
