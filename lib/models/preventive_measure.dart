class PreventiveMeasure {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final bool isActive;
  final int order;
  final String number;

  PreventiveMeasure({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.isActive,
    required this.order,
    required this.number,
  });

  factory PreventiveMeasure.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) => PreventiveMeasure(
    id: id,
    categoryId: data['category_id'] ?? '',
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    isActive: data['is_active'] ?? true,
    order: data['order'] ?? 1,
    number: data['number'] ?? '',
  );

  Map<String, dynamic> toFirestore() => {
    'category_id': categoryId,
    'title': title,
    'description': description,
    'is_active': isActive,
    'order': order,
    'number': number,
    'updated_at': DateTime.now(),
  };

  PreventiveMeasure copyWith({
    String? title,
    String? description,
    bool? isActive,
    int? order,
    String? number,
  }) {
    return PreventiveMeasure(
      id: id,
      categoryId: categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      number: number ?? this.number,
    );
  }
}
