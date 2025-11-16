import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('notifications');

  // READ all notifications (most recent first)
  Future<List<NotificationAlert>> getNotifications() async {
    final querySnapshot = await _collection
        .orderBy('dateTime', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => NotificationAlert.fromFirestore(doc))
        .toList();
  }

  // ADD a notification, returns new document ID
  Future<String> addNotification(NotificationAlert alert) async {
    final docRef = await _collection.add(alert.toFirestore());
    return docRef.id;
  }

  // UPDATE a notification by document ID
  Future<void> updateNotification(String id, NotificationAlert alert) async {
    await _collection.doc(id).update(alert.toFirestore());
  }

  // DELETE a notification by document ID
  Future<void> deleteNotification(String id) async {
    await _collection.doc(id).delete();
  }
}
