/// Scene Category Entity
///
/// Represents a first-level category in the scene hierarchy
/// (e.g., Daily Life, Playground, Numbers & Letters, Festival Scenes)
class SceneCategory {
  final String id;
  final String name;
  final String icon;
  final String coverImage;
  final String description;
  final int sceneCount;
  final int totalItemCount;
  final int order;
  final bool isNew;
  final DateTime createdAt;

  const SceneCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.coverImage,
    required this.description,
    required this.sceneCount,
    required this.totalItemCount,
    required this.order,
    required this.isNew,
    required this.createdAt,
  });

  /// Create from JSON
  factory SceneCategory.fromJson(Map<String, dynamic> json) {
    return SceneCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? json['cover_image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sceneCount: json['sceneCount'] as int? ?? json['scene_count'] as int? ?? 0,
      totalItemCount: json['totalItemCount'] as int? ?? json['total_item_count'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      isNew: json['isNew'] as bool? ?? json['is_new'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'coverImage': coverImage,
      'description': description,
      'sceneCount': sceneCount,
      'totalItemCount': totalItemCount,
      'order': order,
      'isNew': isNew,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  SceneCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? coverImage,
    String? description,
    int? sceneCount,
    int? totalItemCount,
    int? order,
    bool? isNew,
    DateTime? createdAt,
  }) {
    return SceneCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      sceneCount: sceneCount ?? this.sceneCount,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      order: order ?? this.order,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SceneCategory(id: $id, name: $name, sceneCount: $sceneCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SceneCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
