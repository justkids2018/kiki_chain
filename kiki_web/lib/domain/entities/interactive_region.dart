class InteractiveRegion {
  final String type;
  final String id;
  final int index;
  final String text;
  final String textPinyin;
  final String textEnglish;
  final String textPhonetic;
  final List<RegionCoordinate> coordinates;

  InteractiveRegion({
    required this.type,
    required this.id,
    required this.index,
    required this.text,
    required this.textPinyin,
    required this.textEnglish,
    required this.textPhonetic,
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
      textPhonetic: json['text_phonetic'] ?? '',
      coordinates: (json['coordinate'] as List?)
              ?.map((e) => RegionCoordinate.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Parse items_data from either:
  /// 1) Recommended grouped format: one item with nested regions
  /// 2) Legacy flat format: one region per record
  static List<InteractiveRegion> parseItemsData(List<dynamic> itemsData) {
    final result = <InteractiveRegion>[];

    for (final rawItem in itemsData) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);

      final nestedRegions = item['regions'];

      // New grouped schema: flatten nested regions into runtime regions.
      if (nestedRegions is List) {
        final parentId =
            item['id']?.toString() ?? 'chinese_${item['index'] ?? 0}';

        for (var i = 0; i < nestedRegions.length; i++) {
          final rawRegion = nestedRegions[i];
          if (rawRegion is! Map) continue;

          final region = Map<String, dynamic>.from(rawRegion);
          final coordinate = region['coordinate'];
          if (coordinate is! List) continue;

          final regionType = region['region_type']?.toString() ??
              region['region_role']?.toString() ??
              'card';
          final runtimeId =
              region['id']?.toString() ?? '${parentId}_${regionType}_${i + 1}';

          result.add(
            InteractiveRegion.fromJson({
              ...item,
              'id': runtimeId,
              'coordinate': coordinate,
            }),
          );
        }
        continue;
      }

      // Legacy flat schema.
      result.add(InteractiveRegion.fromJson(item));
    }

    return result;
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
