/// 场景学习进度模型
class SceneProgress {
  final String userId;
  final String sceneId;
  final int totalRegions;
  final List<String> learnedRegions;
  final int learnedCount;
  final int starsEarned;
  final bool isCompleted;
  final DateTime? firstLearnedAt;
  final DateTime? lastLearnedAt;
  final int totalStudyTime; // 累计学习时长（秒）

  SceneProgress({
    required this.userId,
    required this.sceneId,
    required this.totalRegions,
    required this.learnedRegions,
    required this.learnedCount,
    required this.starsEarned,
    required this.isCompleted,
    this.firstLearnedAt,
    this.lastLearnedAt,
    this.totalStudyTime = 0,
  });

  /// 从JSON创建
  factory SceneProgress.fromJson(Map<String, dynamic> json) {
    return SceneProgress(
      userId: json['user_id'] as String,
      sceneId: json['scene_id'] as String,
      totalRegions: json['total_regions'] as int,
      learnedRegions: (json['learned_regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      learnedCount: json['learned_count'] as int,
      starsEarned: json['stars_earned'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      firstLearnedAt: json['first_learned_at'] != null
          ? DateTime.parse(json['first_learned_at'] as String)
          : null,
      lastLearnedAt: json['last_learned_at'] != null
          ? DateTime.parse(json['last_learned_at'] as String)
          : null,
      totalStudyTime: json['total_study_time'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'scene_id': sceneId,
      'total_regions': totalRegions,
      'learned_regions': learnedRegions,
      'learned_count': learnedCount,
      'stars_earned': starsEarned,
      'is_completed': isCompleted,
      'first_learned_at': firstLearnedAt?.toIso8601String(),
      'last_learned_at': lastLearnedAt?.toIso8601String(),
      'total_study_time': totalStudyTime,
    };
  }

  /// 复制并更新部分字段
  SceneProgress copyWith({
    String? userId,
    String? sceneId,
    int? totalRegions,
    List<String>? learnedRegions,
    int? learnedCount,
    int? starsEarned,
    bool? isCompleted,
    DateTime? firstLearnedAt,
    DateTime? lastLearnedAt,
    int? totalStudyTime,
  }) {
    return SceneProgress(
      userId: userId ?? this.userId,
      sceneId: sceneId ?? this.sceneId,
      totalRegions: totalRegions ?? this.totalRegions,
      learnedRegions: learnedRegions ?? this.learnedRegions,
      learnedCount: learnedCount ?? this.learnedCount,
      starsEarned: starsEarned ?? this.starsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      lastLearnedAt: lastLearnedAt ?? this.lastLearnedAt,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
    );
  }
}
