class EmergencyHotline {
  final String? id; // Made nullable!
  final String serviceName;
  final String phoneNumber;
  final String category;
  final int priority;
  final bool isActive;
  final String iconType;
  final String iconColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmergencyHotline({
    this.id, // Now optional
    required this.serviceName,
    required this.phoneNumber,
    required this.category,
    required this.priority,
    required this.isActive,
    required this.iconType,
    required this.iconColor,
    this.createdAt,
    this.updatedAt,
  });

  factory EmergencyHotline.fromFirestore(String id, Map<String, dynamic> data) {
    return EmergencyHotline(
      id: id,
      serviceName: data['service_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      category: data['category'] ?? '',
      priority: data['priority'] ?? 0,
      isActive: data['is_active'] ?? true,
      iconType: data['icon_type'] ?? 'call',
      iconColor: data['icon_color'] ?? '#2196F3',
    );
  }

  factory EmergencyHotline.fromJson(Map<String, dynamic> json) {
    return EmergencyHotline(
      id: json['id'] as String?,
      serviceName: json['service_name'] as String,
      phoneNumber: json['phone_number'] as String,
      category: json['category'] as String,
      priority: json['priority'] as int,
      isActive: json['is_active'] as bool,
      iconType: json['icon_type'] as String,
      iconColor: json['icon_color'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'service_name': serviceName,
    'phone_number': phoneNumber,
    'category': category,
    'priority': priority,
    'is_active': isActive,
    'icon_type': iconType,
    'icon_color': iconColor,
    'updated_at': DateTime.now(),
  };

  Map<String, dynamic> toJson() {
    final data = {
      'service_name': serviceName,
      'phone_number': phoneNumber,
      'category': category,
      'priority': priority,
      'is_active': isActive,
      'icon_type': iconType,
      'icon_color': iconColor,
    };
    // Don't include id for creation
    if (id != null && id!.isNotEmpty) data['id'] = id!;
    return data;
  }
}
