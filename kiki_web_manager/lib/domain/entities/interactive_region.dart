class InteractiveRegion {
  final String type;
  final String id;
  final int index;
  final String text;
  final String textPinyin;
  final String textEnglish;
  final List<RegionCoordinate> coordinates;

  InteractiveRegion({
    required this.type,
    required this.id,
    required this.index,
    required this.text,
    required this.textPinyin,
    required this.textEnglish,
    required this.coordinates,
  });

  factory InteractiveRegion.fromJson(Map<String, dynamic> json) {
    return InteractiveRegion(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      index: json['index'] ?? 0,
      text: json['text'] ?? '',
      textPinyin: json['text_pinyin'] ?? '',
      textEnglish: json['text_english'] ?? '',
      coordinates: (json['coordinate'] as List?)
              ?.map((e) => RegionCoordinate.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RegionCoordinate {
  final double x;
  final double y;

  RegionCoordinate({required this.x, required this.y});

  factory RegionCoordinate.fromJson(Map<String, dynamic> json) {
    return RegionCoordinate(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
