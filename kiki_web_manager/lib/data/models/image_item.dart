/// 图片分类枚举
enum ImageCategory {
  child, // 物资
  teacher, // 教师
  life, // 生活
  fruits; // 水果

  String get label {
    switch (this) {
      case ImageCategory.child:
        return '儿童乐园';
      case ImageCategory.teacher:
        return '学校场景';
      case ImageCategory.life:
        return '生活';
      case ImageCategory.fruits:
        return '水果';
    }
  }

  String get icon {
    switch (this) {
      case ImageCategory.child:
        return '📦';
      case ImageCategory.teacher:
        return '👨‍🏫';
      case ImageCategory.life:
        return '🏠';
      case ImageCategory.fruits:
        return '🍎';
    }
  }
}

/// 图片数据模型
class ImageItem {
  final String id;
  final String title;
  final String imagePath;
  final ImageCategory category;
  final String description;
  final String jsonFile;
  final DateTime createdAt;

  ImageItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.jsonFile,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
      category: ImageCategory.values[json['category'] as int],
      description: json['description'] as String? ?? '',
      jsonFile:
          json['jsonFile'] as String? ?? 'assets/data/kiki_zhiwuyuan.json',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imagePath': imagePath,
        'category': category.index,
        'description': description,
        'jsonFile': jsonFile,
        'createdAt': createdAt.toIso8601String(),
      };
}
