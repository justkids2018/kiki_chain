import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/http_client.dart';
import '../../../core/utils/api_response_handler.dart';
import '../../models/learning/scene_progress.dart';

/// 学习进度服务
/// 负责本地缓存和服务器同步
class LearningProgressService {
  static const String _keyPrefix = 'learning_progress_';
  final HttpClient? _httpClient; // 统一使用封装的 HttpClient

  LearningProgressService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 从本地加载场景进度
  Future<SceneProgress?> loadLocalProgress(
      String userId, String sceneId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _buildKey(userId, sceneId);
      final jsonString = prefs.getString(key);

      if (jsonString == null) {
        AppLogger.debug('本地无缓存: $key');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final progress = SceneProgress.fromJson(json);
      AppLogger.info('从本地加载进度: $sceneId, 星星: ${progress.starsEarned}');
      return progress;
    } catch (e) {
      AppLogger.error('加载本地进度失败', e);
      return null;
    }
  }

  /// 保存进度到本地
  Future<bool> saveLocalProgress(SceneProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _buildKey(progress.userId, progress.sceneId);
      final jsonString = jsonEncode(progress.toJson());

      await prefs.setString(key, jsonString);
      AppLogger.info('保存本地进度成功: ${progress.sceneId}');
      return true;
    } catch (e) {
      AppLogger.error('保存本地进度失败', e);
      return false;
    }
  }

  /// 从服务器获取进度
  Future<SceneProgress?> fetchProgressFromServer(
    String userId,
    String sceneId,
  ) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('HTTP客户端未初始化');
      return null;
    }

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/api/v1/learning/progress/$userId/$sceneId',
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);
      return SceneProgress.fromJson(data);
    } catch (e) {
      AppLogger.error('从服务器获取进度失败', e);
      return null;
    }
  }

  /// 从服务器获取用户所有场景进度列表
  Future<List<SceneProgress>> fetchAllUserProgress(String userId) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('HTTP客户端未初始化');
      return [];
    }

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/api/v1/learning/progress/user/$userId/all',
      );

      final data = ApiResponseHandler.handle<List<dynamic>>(response);
      return data
          .map((json) => SceneProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('从服务器获取所有场景进度失败', e);
      return [];
    }
  }

  /// 批量提交学习进度到服务器
  Future<bool> submitProgressToServer({
    required String userId,
    required String sceneId,
    required List<Map<String, dynamic>> learnedRegions,
    required int starsEarned,
    required bool isCompleted,
    required int studyTime,
  }) async {
    final client = _httpClient;
    if (client == null) {
      AppLogger.warning('HTTP客户端未初始化，跳过服务器同步');
      return true; // 本地保存成功即可
    }

    try {
      final response = await client.post<Map<String, dynamic>>(
        '/api/v1/learning/progress/batch',
        data: {
          'user_id': userId,
          'scene_id': sceneId,
          'learned_regions': learnedRegions,
          'stars_earned': starsEarned,
          'is_completed': isCompleted,
          'study_time': studyTime,
        },
      );

      ApiResponseHandler.handle<dynamic>(response);
      AppLogger.info('提交进度到服务器成功');
      return true;
    } catch (e) {
      AppLogger.error('提交进度到服务器失败', e);
      return false;
    }
  }

  /// 构建本地存储的key
  String _buildKey(String userId, String sceneId) {
    return '$_keyPrefix${userId}_$sceneId';
  }

  /// 清除本地缓存（用于调试）
  Future<void> clearLocalCache(String userId, String sceneId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _buildKey(userId, sceneId);
      await prefs.remove(key);
      AppLogger.info('清除本地缓存: $key');
    } catch (e) {
      AppLogger.error('清除本地缓存失败', e);
    }
  }
}
