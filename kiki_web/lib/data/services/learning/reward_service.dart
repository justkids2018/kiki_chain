import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/api_response_handler.dart';
import '../../models/learning/scene_progress.dart';
import '../../../core/network/http_client.dart';

/// 奖励服务 — 3 星制学习进度管理
///
/// 奖励规则（比例制，3 星）：
///   ≥ 30% → 1 星
///   ≥ 60% → 2 星
///   ≥ 100% → 3 星（满星）
///
/// 降级策略：接口失败时不授予星星，保持已有进度不变。
class RewardService {
  static const String _keyPrefix = 'reward_v2_';
  static const String _snapshotPrefix = 'reward_snapshot_v1_';
  static const int maxStars = 3;

  final HttpClient? _httpClient;

  RewardService({HttpClient? httpClient}) : _httpClient = httpClient;

  // ─── 本地持久化 ──────────────────────────────────────────────

  /// 本地存储 Key
  String _buildKey(String userId, String sceneId) =>
      '$_keyPrefix${userId}_$sceneId';

  /// 从本地加载已学习的词 IDs（Set<String>）
  Future<Set<String>> loadLearnedRegionIds(
    String userId,
    String sceneId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_buildKey(userId, sceneId));
      return raw?.toSet() ?? {};
    } catch (e) {
      AppLogger.error('RewardService: 读取本地进度失败', e);
      return {};
    }
  }

  /// 一次读取多个场景的已学词数，避免地图按节点重复初始化存储。
  Future<Map<String, int>> loadLearnedRegionCounts(
    String userId,
    Iterable<String> sceneIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        for (final sceneId in sceneIds)
          sceneId: prefs.getStringList(_buildKey(userId, sceneId))?.length ?? 0,
      };
    } catch (e) {
      AppLogger.error('RewardService: 批量读取本地进度失败', e);
      return {};
    }
  }

  /// 保存已学习词 IDs 到本地
  Future<void> saveLearnedRegionIds(
    String userId,
    String sceneId,
    Set<String> learnedIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _buildKey(userId, sceneId),
        learnedIds.toList(),
      );
    } catch (e) {
      AppLogger.error('RewardService: 保存本地进度失败', e);
    }
  }

  // ─── 星星计算 ─────────────────────────────────────────────────

  /// 根据已学数量和总数计算应得星星数（0~3）
  int calculateStars(int learned, int total) {
    if (total <= 0) return 0;
    final ratio = learned / total;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.6) return 2;
    if (ratio >= 0.3) return 1;
    return 0;
  }

  // ─── 服务器接口 ───────────────────────────────────────────────

  /// 从服务器拉取场景进度（进入页面时调用）
  ///
  /// 返回 null 表示接口失败或无历史记录。
  Future<SceneProgress?> fetchProgressFromServer(
    String userId,
    String sceneId,
  ) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('RewardService: HTTP 客户端未初始化，跳过服务器拉取');
      return null;
    }

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/api/v1/learning/progress/$userId/$sceneId',
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);
      final learnedRaw = data['learned_regions'];
      final learnedList = learnedRaw is List
          ? learnedRaw.map((e) => e.toString()).toList()
          : <String>[];
      final progress = SceneProgress(
        userId: userId,
        sceneId: sceneId,
        totalRegions: (data['total_regions'] as num?)?.toInt() ?? 0,
        learnedRegions: learnedList,
        learnedCount: learnedList.length,
        starsEarned: (data['stars_earned'] as num?)?.toInt() ?? 0,
        isCompleted: data['is_completed'] as bool? ?? false,
      );
      AppLogger.info(
          'RewardService: 从服务器加载进度成功 — ${progress.learnedCount} 词 / ${progress.starsEarned} 星');
      return progress;
    } catch (e) {
      AppLogger.warning('RewardService: 拉取服务器进度失败，使用本地数据', e);
      return null;
    }
  }

  /// 读取全局进度快照。每个用户在 6、17、20 点三个时间窗口各最多请求一次。
  Future<List<SceneProgress>> loadProgressSnapshot(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (userId.isEmpty) return const [];
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_snapshotPrefix${userId}_data';
    final slotKey = '$_snapshotPrefix${userId}_slot';
    final cached = _decodeProgressSnapshot(prefs.getString(cacheKey));
    final currentSlot = _currentRefreshSlot();
    if (!forceRefresh && prefs.getString(slotKey) == currentSlot) {
      return cached;
    }

    final latest = await _fetchAllProgressFromServer(userId);
    if (latest == null) {
      // 失败也记录当前窗口，避免孩子切换主题时连续重试。
      await prefs.setString(slotKey, currentSlot);
      return cached;
    }
    await prefs.setString(
      cacheKey,
      jsonEncode(latest.map((progress) => progress.toJson()).toList()),
    );
    await prefs.setString(slotKey, currentSlot);
    return latest;
  }

  Future<List<SceneProgress>?> _fetchAllProgressFromServer(
      String userId) async {
    final client = _httpClient;
    if (client == null || userId.isEmpty) return null;

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/api/v1/learning/progress/user/$userId/all',
      );
      final data = ApiResponseHandler.handle<List<dynamic>>(response);
      return data
          .whereType<Map<String, dynamic>>()
          .map(SceneProgress.fromJson)
          .toList(growable: false);
    } catch (e) {
      AppLogger.warning('RewardService: 批量拉取服务器进度失败，使用本地摘要', e);
      return null;
    }
  }

  List<SceneProgress> _decodeProgressSnapshot(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SceneProgress.fromJson)
          .toList(growable: false);
    } catch (e) {
      AppLogger.warning('RewardService: 进度快照解析失败', e);
      return const [];
    }
  }

  String _currentRefreshSlot() {
    final now = DateTime.now();
    // 学习日从早上 6 点开始，凌晨沿用前一晚快照，不额外请求。
    final learningDate =
        now.hour < 6 ? now.subtract(const Duration(days: 1)) : now;
    final date = '${learningDate.year.toString().padLeft(4, '0')}-'
        '${learningDate.month.toString().padLeft(2, '0')}-'
        '${learningDate.day.toString().padLeft(2, '0')}';
    final period = now.hour < 6
        ? 'after_20'
        : now.hour < 17
            ? '06_to_17'
            : now.hour < 20
                ? '17_to_20'
                : 'after_20';
    return '${date}_$period';
  }

  /// 提交学习进度到服务器（退出页面或获得新星星时调用）
  ///
  /// 返回最新用户总星星数，失败时返回 null 并静默忽略。
  Future<int?> submitProgressToServer({
    required String userId,
    required String sceneId,
    required Set<String> learnedRegionIds,
    required int starsEarned,
    required bool isCompleted,
    required int studyTimeSeconds,
  }) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('RewardService: HTTP 客户端未初始化，跳过服务器提交');
      return null;
    }

    try {
      final learnedRegions = learnedRegionIds
          .map((id) => {
                'region_id': id,
                'region_text': id,
                'region_text_english': id, // 补齐必填字段，防止后端 JSON 解析失败
                'learned_at': DateTime.now().toIso8601String(),
              })
          .toList();

      final response = await client.post<Map<String, dynamic>>(
        '/api/v1/learning/progress/batch',
        data: {
          'user_id': userId,
          'scene_id': sceneId,
          'learned_regions': learnedRegions,
          'stars_earned': starsEarned,
          'is_completed': isCompleted,
          'study_time': studyTimeSeconds,
        },
      );

      AppLogger.info('RewardService: 进度提交成功: $response');
      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);
      return (data['user_total_stars'] as num?)?.toInt();
    } catch (e) {
      AppLogger.warning('RewardService: 进度提交失败（静默忽略）', e);
      return null;
    }
  }

  /// 从服务器拉取用户总星星数
  Future<int?> fetchUserTotalStars(String userId) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('RewardService: HTTP 客户端未初始化，跳过拉取用户汇总');
      return null;
    }

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/api/v1/learning/user/$userId/summary',
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);
      final totalStars = (data['total_stars'] as num?)?.toInt();
      AppLogger.info('RewardService: 获取用户总星星数成功 — $totalStars 颗星');
      return totalStars;
    } catch (e) {
      AppLogger.warning('RewardService: 获取用户总星星数失败', e);
      return null;
    }
  }
}
