/// SceneItem Entity - 场景物品实体
///
/// 表示场景中的一个学习物品，包含物品的名称、发音、图片等信息
class SceneItem {
  final String id;
  final String sceneId;
  final String nameCn;
  final String nameEn;
  final String pinyin;
  final String pronunciation;
  final String imageUrl;
  final String audioUrl;
  final int order;
  final Map<String, dynamic>? hotspot; // 热区坐标信息 {x, y, width, height}

  const SceneItem({
    required this.id,
    required this.sceneId,
    required this.nameCn,
    required this.nameEn,
    required this.pinyin,
    required this.pronunciation,
    required this.imageUrl,
    required this.audioUrl,
    required this.order,
    this.hotspot,
  });

  factory SceneItem.fromJson(Map<String, dynamic> json) {
    return SceneItem(
      id: json['id'] as String,
      sceneId: json['sceneId'] as String? ?? json['scene_id'] as String? ?? '',
      nameCn: json['nameCn'] as String? ?? json['name_cn'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name_en'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? json['audio_url'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      hotspot: json['hotspot'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sceneId': sceneId,
      'nameCn': nameCn,
      'nameEn': nameEn,
      'pinyin': pinyin,
      'pronunciation': pronunciation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'order': order,
      'hotspot': hotspot,
    };
  }

  SceneItem copyWith({
    String? id,
    String? sceneId,
    String? nameCn,
    String? nameEn,
    String? pinyin,
    String? pronunciation,
    String? imageUrl,
    String? audioUrl,
    int? order,
    Map<String, dynamic>? hotspot,
  }) {
    return SceneItem(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      nameCn: nameCn ?? this.nameCn,
      nameEn: nameEn ?? this.nameEn,
      pinyin: pinyin ?? this.pinyin,
      pronunciation: pronunciation ?? this.pronunciation,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      order: order ?? this.order,
      hotspot: hotspot ?? this.hotspot,
    );
  }

  @override
  String toString() {
    return 'SceneItem(id: $id, nameCn: $nameCn, nameEn: $nameEn, sceneId: $sceneId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SceneItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
