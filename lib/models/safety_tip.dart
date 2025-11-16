class SafetyTip {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String? level; // <-- add this
  final bool isActive;
  final int order;

  SafetyTip({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    this.level,
    required this.isActive,
    required this.order,
  });

  factory SafetyTip.fromFirestore(String id, Map<String, dynamic> data) =>
      SafetyTip(
        id: id,
        categoryId: data['category_id'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        level: data['level'], // <-- use this
        isActive: data['is_active'] ?? true,
        order: data['order'] ?? 0,
      );

  Map<String, dynamic> toFirestore() => {
    'category_id': categoryId,
    'title': title,
    'description': description,
    'level': level,
    'is_active': isActive,
    'order': order,
    'updated_at': DateTime.now(),
  };

  SafetyTip copyWith({String? description}) {
    return SafetyTip(
      id: id,
      categoryId: categoryId,
      title: title,
      description: description ?? this.description,
      level: level,
      isActive: isActive,
      order: order,
    );
  }
}
