import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManagementService {
  final CollectionReference _adminCollection = FirebaseFirestore.instance
      .collection('admin');

  /// Fetch all admins from Firestore
  Future<List<Map<String, dynamic>>> fetchAdmins() async {
    final snapshot = await _adminCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      // Provide default values if columns are missing
      return {
        'id': doc.id,
        'username': data['username'] ?? '',
        'email': data['email'] ?? '',
        'role': data['role'] ?? 'admin',
      };
    }).toList();
  }

  /// Add a new admin
  Future<void> addAdmin(Map<String, dynamic> adminData) async {
    // Set default values if missing
    final data = {
      'username': adminData['username'] ?? '',
      'email': adminData['email'] ?? '',
      'role': adminData['role'] ?? 'admin',
    };
    await _adminCollection.add(data);
  }

  /// Edit an admin by document ID
  Future<void> editAdmin(String docId, Map<String, dynamic> adminData) async {
    final data = {
      'username': adminData['username'] ?? '',
      'email': adminData['email'] ?? '',
      'role': adminData['role'] ?? 'admin',
    };
    await _adminCollection.doc(docId).update(data);
  }

  /// Delete an admin by document ID
  Future<void> deleteAdmin(String docId) async {
    await _adminCollection.doc(docId).delete();
  }

  /// Get a single admin by document ID
  Future<Map<String, dynamic>?> getAdmin(String docId) async {
    final doc = await _adminCollection.doc(docId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      'username': data['username'] ?? '',
      'email': data['email'] ?? '',
      'role': data['role'] ?? 'admin',
    };
  }
}
