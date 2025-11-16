import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? suffix;
  final String phoneNumber;
  final String houseAddress;
  final String barangay;
  final String role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.suffix,
    required this.phoneNumber,
    required this.houseAddress,
    required this.barangay,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    List<String> nameParts = [firstName];
    if (middleName?.isNotEmpty == true) nameParts.add(middleName!);
    nameParts.add(lastName);
    if (suffix?.isNotEmpty == true) nameParts.add(suffix!);
    return nameParts.join(' ');
  }

  String get fullAddress => '$houseAddress, $barangay';

  String get status => isVerified ? 'Active' : 'Inactive';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      middleName: data['middle_name'],
      suffix: data['suffix'],
      phoneNumber: data['phone_number'] ?? '',
      houseAddress: data['house_address'] ?? '',
      barangay: data['barangay'] ?? '',
      role: data['role'] ?? 'Users',
      isVerified: data['is_verified'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'suffix': suffix,
      'phone_number': phoneNumber,
      'house_address': houseAddress,
      'barangay': barangay,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt,
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Convert to the format expected by your current UI
  Map<String, String> toDisplayMap() {
    return {
      'id': id,
      'name': fullName,
      'contact': phoneNumber,
      'address': fullAddress,
      'role': role,
      'status': status,
    };
  }
}

class UserService {
  static final UserService instance = UserService._();
  UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Get all users as a stream
  Stream<List<UserModel>> getUsersStream() {
    return _db
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Get all users (one-time fetch)
  Future<List<UserModel>> getUsers() async {
    final snapshot = await _db
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Add a new user
  Future<String> addUser(UserModel user) async {
    final docRef = await _db.collection(_collection).add(user.toFirestore());
    return docRef.id;
  }

  // Update an existing user
  Future<void> updateUser(String id, UserModel user) async {
    await _db.collection(_collection).doc(id).update(user.toFirestore());
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // Check if phone number exists (for duplicate validation)
  Future<bool> phoneNumberExists(
    String phoneNumber, {
    String? excludeId,
  }) async {
    Query query = _db
        .collection(_collection)
        .where('phone_number', isEqualTo: phoneNumber);

    final snapshot = await query.get();
    if (excludeId != null) {
      // Exclude the current user being edited
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return snapshot.docs.isNotEmpty;
  }

  // Toggle user verification status
  Future<void> toggleUserVerification(String id, bool isVerified) async {
    await _db.collection(_collection).doc(id).update({
      'is_verified': isVerified,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
