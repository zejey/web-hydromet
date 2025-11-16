import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_tip.dart';

class SafetyTipService {
  static final _db = FirebaseFirestore.instance;
  static final _collection = _db.collection('safety_tips');

  static Stream<List<SafetyTip>> getTipsForCategory(String categoryId) =>
      _collection
          .where('category_id', isEqualTo: categoryId)
          .where('is_active', isEqualTo: true)
          .orderBy('order')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => SafetyTip.fromFirestore(doc.id, doc.data()))
                .toList(),
          );

  static Future<void> addTip(SafetyTip tip) async {
    await _collection.add(tip.toFirestore());
  }

  static Future<void> updateTip(SafetyTip tip) async {
    await _collection.doc(tip.id).update(tip.toFirestore());
  }

  static Future<void> deleteTip(String id) async {
    await _collection.doc(id).delete();
  }
}
