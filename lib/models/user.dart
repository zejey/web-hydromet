class UserModel {
  final String? id;
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
    this.id,
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

  factory UserModel.fromJson(Map<String, dynamic> data) => UserModel(
        id: data['id'] as String?,
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        middleName: data['middle_name'],
        suffix: data['suffix'],
        phoneNumber: data['phone_number'] ?? '',
        houseAddress: data['house_address'] ?? '',
        barangay: data['barangay'] ?? '',
        role: data['role'] ?? 'Users',
        isVerified: data['is_verified'] ?? false,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (suffix != null) 'suffix': suffix,
      'phone_number': phoneNumber,
      'house_address': houseAddress,
      'barangay': barangay,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, String> toDisplayMap() => {
        'id': id ?? '',
        'name': fullName,
        'contact': phoneNumber,
        'address': fullAddress,
        'role': role,
        'status': status,
      };
}
