import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preventive_measure.dart';

class PreventiveMeasureService {
  static final _db = FirebaseFirestore.instance;
  static final _collection = _db.collection('preventive_measures');

  static Stream<List<PreventiveMeasure>> getMeasuresForCategory(
    String categoryId,
  ) => _collection
      .where('category_id', isEqualTo: categoryId)
      .where('is_active', isEqualTo: true)
      .orderBy('order')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PreventiveMeasure.fromFirestore(doc.id, doc.data()))
            .toList(),
      );

  static Future<void> addMeasure(PreventiveMeasure measure) async {
    final existing = await _collection
        .where('category_id', isEqualTo: measure.categoryId)
        .where('is_active', isEqualTo: true)
        .orderBy('order')
        .get();
    final nextOrder = existing.docs.length + 1;
    final number = nextOrder.toString().padLeft(2, '0');
    await _collection.add(
      measure.copyWith(order: nextOrder, number: number).toFirestore(),
    );
  }

  static Future<void> updateMeasure(PreventiveMeasure measure) async {
    await _collection.doc(measure.id).update(measure.toFirestore());
  }

  static Future<void> deleteMeasure(String id, String categoryId) async {
    await _collection.doc(id).delete();

    final snap = await _collection
        .where('category_id', isEqualTo: categoryId)
        .where('is_active', isEqualTo: true)
        .orderBy('order')
        .get();

    int i = 1;
    for (final doc in snap.docs) {
      final number = i.toString().padLeft(2, '0');
      await doc.reference.update({'order': i, 'number': number});
      i++;
    }
  }
}
