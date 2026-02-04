import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_item.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';

/// 场景详情控制器
///
/// 管理场景详情页面的状态和业务逻辑
class SceneDetailController extends GetxController {
  SceneDetailController({
    ISceneRepository? sceneRepository,
    required this.scene,
  }) : _sceneRepository =
            sceneRepository ?? ServiceLocator.instance.sceneRepository;

  final Scene scene;
  final ISceneRepository _sceneRepository;

  // 场景物品列表
  final RxList<SceneItem> items = <SceneItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Helper to get localizations
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  @override
  void onInit() {
    super.onInit();
    loadSceneDetail();
  }

  /// 加载场景详情
  Future<void> loadSceneDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.info('📦 Loading scene detail: ${scene.id}');

      final result = await _sceneRepository.getSceneDetail(scene.id);

      // 解析物品列表
      final itemsJson = result['items'] as List<dynamic>?;
      if (itemsJson != null) {
        items.value = itemsJson
            .map((json) => SceneItem.fromJson(json as Map<String, dynamic>))
            .toList();

        // 按 order 排序
        items.sort((a, b) => a.order.compareTo(b.order));
      }

      AppLogger.info('✅ Loaded ${items.length} items');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to load scene detail', e, stackTrace);
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理点击事件
  void handleTap(Offset position) {
    AppLogger.debug('🖱️ Tap at position: $position');

    // TODO: 实现热点检测逻辑
    // 遍历所有物品，检查点击位置是否在热点区域内
    for (final item in items) {
      if (item.hotspot != null && _isPointInHotspot(position, item.hotspot!)) {
        _showItemDialog(item);
        return;
      }
    }

    // 如果没有点击到任何热点，显示提示
    Get.snackbar(
      _l10n.hint,
      _l10n.clickItemHint,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      colorText: Colors.white,
    );
  }

  /// 检查点是否在热点区域内
  bool _isPointInHotspot(Offset point, Map<String, dynamic> hotspot) {
    // TODO: 实现热点检测算法
    // 支持矩形、圆形、多边形等形状
    final type = hotspot['type'] as String?;

    if (type == 'rect') {
      final x = hotspot['x'] as double;
      final y = hotspot['y'] as double;
      final width = hotspot['width'] as double;
      final height = hotspot['height'] as double;

      return point.dx >= x &&
          point.dx <= x + width &&
          point.dy >= y &&
          point.dy <= y + height;
    } else if (type == 'circle') {
      final centerX = hotspot['x'] as double;
      final centerY = hotspot['y'] as double;
      final radius = hotspot['radius'] as double;

      final distance = (point - Offset(centerX, centerY)).distance;
      return distance <= radius;
    }

    return false;
  }

  /// 显示物品信息对话框
  void _showItemDialog(SceneItem item) {
    AppLogger.info('📱 Showing item dialog: ${item.nameCn}');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 物品图片
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 中文名称
              Text(
                item.nameCn,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),

              // 拼音
              Text(
                item.pinyin,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),

              // 英文名称
              Text(
                item.nameEn,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // 播放按钮
              ElevatedButton.icon(
                onPressed: () => _playAudio(item),
                icon: const Icon(Icons.volume_up),
                label: Text(_l10n.playPronunciation),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 关闭按钮
              TextButton(
                onPressed: () => Get.back(),
                child: Text(_l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 播放音频
  void _playAudio(SceneItem item) {
    AppLogger.info('🔊 Playing audio: ${item.audioUrl}');

    // TODO: 实现音频播放功能
    Get.snackbar(
      _l10n.hint,
      _l10n.playingAudio(item.nameCn),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      colorText: Colors.white,
    );
  }
}
