// 图片分类和数据模型
enum ImageCategory {
  teacher,    // 教师
  supplies,   // 物资
  life,       // 生活
  fruits;     // 水果

  String get label {
    switch (this) {
      case ImageCategory.teacher:
        return '教师';
      case ImageCategory.supplies:
        return '物资';
      case ImageCategory.life:
        return '生活';
      case ImageCategory.fruits:
        return '水果';
    }
  }

  String get icon {
    switch (this) {
      case ImageCategory.teacher:
        return '👨‍🏫';
      case ImageCategory.supplies:
        return '📦';
      case ImageCategory.life:
        return '🏠';
      case ImageCategory.fruits:
        return '🍎';
    }
  }
}

// 图片数据模型
class ImageItem {
  final String id;
  final String title;
  final String imagePath;
  final ImageCategory category;
  final String description;
  final DateTime createdAt;

  ImageItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.category,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
      category: ImageCategory.values[json['category'] as int],
      description: json['description'] as String? ?? '',
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
    'createdAt': createdAt.toIso8601String(),
  };
}

// 模拟数据源
class ImageDataSource {
  static List<ImageItem> getItems() {
    return [
      // 教师分类
      ImageItem(
        id: 'teacher_1',
        title: '李老师',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.teacher,
        description: '一年级语文老师',
      ),
      ImageItem(
        id: 'teacher_2',
        title: '王老师',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.teacher,
        description: '数学老师',
      ),
      ImageItem(
        id: 'teacher_3',
        title: '张老师',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.teacher,
        description: '英语老师',
      ),

      // 物资分类
      ImageItem(
        id: 'supplies_1',
        title: '教科书',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.supplies,
        description: '学校教科书',
      ),
      ImageItem(
        id: 'supplies_2',
        title: '文具',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.supplies,
        description: '笔和本子',
      ),
      ImageItem(
        id: 'supplies_3',
        title: '黑板',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.supplies,
        description: '教室黑板',
      ),

      // 生活分类
      ImageItem(
        id: 'life_1',
        title: '宿舍',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.life,
        description: '学生宿舍',
      ),
      ImageItem(
        id: 'life_2',
        title: '食堂',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.life,
        description: '学校食堂',
      ),
      ImageItem(
        id: 'life_3',
        title: '操场',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.life,
        description: '学校操场',
      ),

      // 水果分类
      ImageItem(
        id: 'fruits_1',
        title: '苹果',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.fruits,
        description: '新鲜苹果',
      ),
      ImageItem(
        id: 'fruits_2',
        title: '香蕉',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.fruits,
        description: '黄色香蕉',
      ),
      ImageItem(
        id: 'fruits_3',
        title: '橙子',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.fruits,
        description: '甜橙子',
      ),
      ImageItem(
        id: 'fruits_4',
        title: '葡萄',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.fruits,
        description: '紫葡萄',
      ),
    ];
  }

  static List<ImageItem> getItemsByCategory(ImageCategory category) {
    return getItems().where((item) => item.category == category).toList();
  }
}
