import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationAlert {
  String id;
  String type;
  String title;
  String message;
  DateTime dateTime;
  String status;
  int sentTo;

  NotificationAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.status,
    required this.sentTo,
  });

  factory NotificationAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationAlert(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'Active',
      sentTo: data['sentTo'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'sentTo': sentTo,
    };
  }
}
