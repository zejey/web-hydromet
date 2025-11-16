import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_hotline.dart';

class HotlineService {
  static final _db = FirebaseFirestore.instance;
  static final _collection = _db.collection('emergency_hotlines');

  static Stream<List<EmergencyHotline>> getHotlinesStream() => _collection
      .orderBy('priority')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => EmergencyHotline.fromFirestore(doc.id, doc.data()))
            .toList(),
      );

  static Future<void> addHotline(EmergencyHotline hotline) async {
    await _collection.doc(hotline.id).set(hotline.toFirestore());
  }

  static Future<void> updateHotline(EmergencyHotline hotline) async {
    await _collection.doc(hotline.id).update(hotline.toFirestore());
  }

  static Future<void> deleteHotline(String id) async {
    await _collection.doc(id).delete();
  }
}
