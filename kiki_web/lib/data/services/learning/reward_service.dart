import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/app_logger.dart';
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
      final response = await client.get(
        '/api/v1/learning/progress/$userId/$sceneId',
      );

      if (response['code'] == 0 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
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
      }
      AppLogger.info('RewardService: 服务器无历史进度 (scene=$sceneId)');
      return null;
    } catch (e) {
      AppLogger.warning('RewardService: 拉取服务器进度失败，使用本地数据', e);
      return null;
    }
  }

  /// 提交学习进度到服务器（退出页面或获得新星星时调用）
  ///
  /// 失败时静默忽略（不影响本地体验）。
  Future<void> submitProgressToServer({
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
      return;
    }

    try {
      final learnedRegions = learnedRegionIds
          .map((id) => {
                'region_id': id,
                'region_text': id,
                'learned_at': DateTime.now().toIso8601String(),
              })
          .toList();

      await client.post(
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
      AppLogger.info('RewardService: 进度提交成功');
    } catch (e) {
      AppLogger.warning('RewardService: 进度提交失败（静默忽略）', e);
    }
  }
}
