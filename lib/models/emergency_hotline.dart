class EmergencyHotline {
  final String id;
  final String serviceName;
  final String phoneNumber;
  final String category;
  final int priority;
  final bool isActive;
  final String iconType;
  final String iconColor;

  EmergencyHotline({
    required this.id,
    required this.serviceName,
    required this.phoneNumber,
    required this.category,
    required this.priority,
    required this.isActive,
    required this.iconType,
    required this.iconColor,
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
}
