import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/network_client.dart';
import '../../data/models/learning/scene_progress.dart';
import '../../data/services/learning/learning_progress_service.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/i_scene_repository.dart';
import 'auth_controller.dart';

class LearningRecordController extends GetxController {
  final ISceneRepository _sceneRepository;
  final LearningProgressService _progressService;

  final RxList<SceneProgress> progressList = <SceneProgress>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Grouped data: Map<MonthString, Map<WeekString, List<SceneProgress>>>
  // e.g. "6月" -> { "6月8日 - 6月14日": [ progress1, progress2 ] }
  final RxMap<String, Map<String, List<SceneProgress>>> groupedRecords =
      <String, Map<String, List<SceneProgress>>>{}.obs;

  // Sorted list of months for displaying Month Cards
  final RxList<String> activeMonths = <String>[].obs;

  // Daily records map for GitHub-style heatmap: Map<YYYY-MM-DD, List<SceneProgress>>
  final RxMap<String, List<SceneProgress>> dailyRecords =
      <String, List<SceneProgress>>{}.obs;

  // Scene names cache map: Map<sceneId, sceneName>
  final RxMap<String, String> sceneNames = <String, String>{}.obs;

  LearningRecordController({
    ISceneRepository? sceneRepository,
    LearningProgressService? progressService,
  })  : _sceneRepository =
            sceneRepository ?? ServiceLocator.instance.sceneRepository,
        _progressService = progressService ??
            LearningProgressService(httpClient: NetworkClient.instance.httpClient);

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  /// Prefetch scene names cache across all categories
  Future<void> _loadSceneNames() async {
    try {
      AppLogger.info('🎨 Prefetching scene names cache...');
      final categories = await _sceneRepository.getCategories();
      for (final cat in categories) {
        final scenes = await _sceneRepository.getScenesByCategory(cat.id);
        for (final scene in scenes) {
          sceneNames[scene.id] = scene.name;
        }
      }
      AppLogger.info('✅ Cached ${sceneNames.length} scene names');
    } catch (e) {
      AppLogger.warning('⚠️ Failed to prefetch scene names: $e');
    }
  }

  Future<void> loadRecords() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      progressList.clear();
      groupedRecords.clear();
      activeMonths.clear();
      dailyRecords.clear();

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.id ?? '';
      if (userId.isEmpty) {
        errorMessage.value = '用户未登录';
        return;
      }

      // 1. Prefetch scene names
      await _loadSceneNames();

      // 2. Fetch learning progresses from server
      AppLogger.info('📊 Fetching all learning progress for user: $userId');
      final result = await _progressService.fetchAllUserProgress(userId);
      progressList.value = result;

      // 3. Group records
      _groupRecords();
      AppLogger.info('✅ Grouped progress list into ${activeMonths.length} months');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to load learning records', e, stackTrace);
      errorMessage.value = '加载学习记录失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _groupRecords() {
    final Map<String, Map<String, List<SceneProgress>>> tempGrouped = {};
    final Map<String, List<SceneProgress>> tempDaily = {};

    // Group all records (removing the current year restriction to support cross-year display)
    for (final progress in progressList) {
      final dateUtc = progress.lastLearnedAt ?? progress.firstLearnedAt ?? DateTime.now();
      final date = dateUtc.toLocal(); // Convert to local timezone

      // 1. Group by Month (e.g. "6月", "5月")
      final monthStr = '${date.month}月';

      // 2. Group by Calendar Week containing this date
      final weekStr = _getWeekRangeString(date);

      tempGrouped.putIfAbsent(monthStr, () => {});
      tempGrouped[monthStr]!.putIfAbsent(weekStr, () => []);
      tempGrouped[monthStr]![weekStr]!.add(progress);

      // 3. Daily grouping for contribution heatmap (Key format: YYYY-MM-DD)
      final dailyKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      tempDaily.putIfAbsent(dailyKey, () => []);
      tempDaily[dailyKey]!.add(progress);
    }

    // Sort months in descending order (recent months first)
    final sortedMonths = tempGrouped.keys.toList()
      ..sort((a, b) {
        final aNum = int.parse(a.replaceAll('月', ''));
        final bNum = int.parse(b.replaceAll('月', ''));
        return bNum.compareTo(aNum);
      });

    groupedRecords.value = tempGrouped;
    activeMonths.assignAll(sortedMonths);
    dailyRecords.value = tempDaily;
  }

  String _getWeekRangeString(DateTime date) {
    // Find the Monday of the week
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    
    return '${monday.month}月${monday.day}日 - ${sunday.month}月${sunday.day}日';
  }

  /// Click action: fetch scene detail and redirect to Interactive Image page
  Future<void> continueLearning(String sceneId) async {
    try {
      isLoading.value = true;
      AppLogger.info('🚀 Continuing learning for scene: $sceneId');
      
      // Fetch full scene details (which contains items_data for interactive region rendering)
      final sceneData = await _sceneRepository.getSceneDetail(sceneId);
      final scene = Scene.fromJson(sceneData);

      Get.toNamed(
        AppConstants.routeInteractiveImage,
        arguments: {
          'jsonFile': scene.dataFile,
          'imageItem': null,
          'images': <dynamic>[],
          'scene': sceneData,
          'sceneObject': scene,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load scene details for redirection: $sceneId', e);
      Get.snackbar('提示', '加载场景失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }
}
