/// Scene Entity - 场景实体
///
/// 表示一个学习场景，包含场景的基本信息和物品列表
class Scene {
  final String id;
  final String name;
  final String nameEn;
  final String categoryId;
  final String coverImage;
  final String interactiveImage;
  final String description;
  final String context;
  final int itemCount;
  final int order;
  final bool isNew;
  final DateTime createdAt;

  const Scene({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.categoryId,
    required this.coverImage,
    required this.interactiveImage,
    required this.description,
    required this.context,
    required this.itemCount,
    required this.order,
    required this.isNew,
    required this.createdAt,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String? ?? json['name_en'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? json['category_id'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? json['cover_image'] as String? ?? '',
      interactiveImage: json['interactiveImage'] as String? ?? json['interactive_image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      context: json['context'] as String? ?? '',
      itemCount: json['itemCount'] as int? ?? json['item_count'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      isNew: json['isNew'] as bool? ?? json['is_new'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'categoryId': categoryId,
      'coverImage': coverImage,
      'interactiveImage': interactiveImage,
      'description': description,
      'context': context,
      'itemCount': itemCount,
      'order': order,
      'isNew': isNew,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Scene copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? categoryId,
    String? coverImage,
    String? interactiveImage,
    String? description,
    String? context,
    int? itemCount,
    int? order,
    bool? isNew,
    DateTime? createdAt,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      categoryId: categoryId ?? this.categoryId,
      coverImage: coverImage ?? this.coverImage,
      interactiveImage: interactiveImage ?? this.interactiveImage,
      description: description ?? this.description,
      context: context ?? this.context,
      itemCount: itemCount ?? this.itemCount,
      order: order ?? this.order,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Scene(id: $id, name: $name, categoryId: $categoryId, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Scene && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
