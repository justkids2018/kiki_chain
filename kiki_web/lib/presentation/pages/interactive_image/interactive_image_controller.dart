import 'dart:async';
import 'package:get/get.dart';
import '../../../core/logging/app_logger.dart';
import '../../../data/models/image_item.dart';
import '../../../domain/entities/interactive_region.dart';
import '../../../data/repositories/interactive_image/i_interactive_image_repository.dart';
import '../../../data/repositories/interactive_image/interactive_image_repository_impl.dart';
import '../../../core/speech/audio_playback_component.dart';
import '../../../data/services/learning/learning_progress_service.dart';
import '../../../data/models/learning/scene_progress.dart';
import '../../widgets/stroke_animation/stroke_speed_config.dart';

class InteractiveImageController extends GetxController {
  late final IInteractiveImageRepository _repository;
  late final AudioPlaybackComponent _audioPlayback;
  late final LearningProgressService _progressService;

  final regions = <InteractiveRegion>[].obs;
  final imageWidth = 1.0.obs;
  final imageHeight = 1.0.obs;
  final isLoaded = false.obs;
  final errorMessage = RxnString();
  final loadingProgress = 0.0.obs;

  // UI State
  final isAutoPlay = false.obs;
  final activeRegion = Rxn<InteractiveRegion>();
  final currentCharIndex = (-1).obs; // -1 indicates no active animation
  final visibleCharCount = 0.obs;
  final totalCharCount = 0.obs;
  final animationSpeed = 2.0.obs; // 动画速度：点击图片时更快(3.0)，点击单字时稍快(2.0)
  String? _lastInitializedText;
  bool _singleCharacterMode = false;
  bool _hasTtsPlaybackError = false;

  // 动态数据：从导航参数接收
  late String _jsonFilePath;
  late String _imagePath;

  // 当前图片项和所有图片列表
  ImageItem? _currentImageItem;
  List<ImageItem> _imagesList = [];

  // 场景对象（包含内嵌的 items_data）
  dynamic _scene;

  InteractiveImageController({
    IInteractiveImageRepository? repository,
    AudioPlaybackComponent? audioPlayback,
    LearningProgressService? progressService,
  }) {
    _repository = repository ?? InteractiveImageRepositoryImpl();
    _audioPlayback = audioPlayback ?? AudioPlaybackComponent();
    _progressService = progressService ?? LearningProgressService();

    // 从导航参数获取文件路径和图片路径
    _getParametersFromRoute();
  }

  /// 从路由参数获取 JSON 文件、图片路径、ImageItem、图片列表和场景对象
  void _getParametersFromRoute() {
    // 获取传递的参数
    final arguments = Get.arguments;

    if (arguments != null && arguments is Map) {
      // 接收 scene 对象（新的数据结构，优先级最高）
      if (arguments['scene'] != null) {
        _scene = arguments['scene'];
        // 从 scene 对象中提取图片路径
        if (_scene is Map) {
          _imagePath = _resolveSceneImagePath(_scene);
        } else {
          // 如果是 Scene 对象，直接访问属性
          try {
            _imagePath = _scene.interactiveImage ?? '';
          } catch (e) {
            AppLogger.warning(
                'Failed to extract image path from scene object', e);
            _imagePath = '';
          }
        }
        // jsonFile 可能为 null（新数据结构中数据内嵌在 scene 中）
        _jsonFilePath = arguments['jsonFile'] ?? '';
        AppLogger.info('Using scene object with embedded data');
        AppLogger.info(
            'Scene name: ${_scene is Map ? _scene['name'] : (_scene?.name ?? 'unknown')}');
      }
      // 接收 ImageItem（次优先）
      else if (arguments['imageItem'] != null &&
          arguments['imageItem'] is ImageItem) {
        _currentImageItem = arguments['imageItem'] as ImageItem;
        _jsonFilePath = _currentImageItem!.jsonFile;
        _imagePath = _currentImageItem!.imagePath;
      } else {
        // 降级：使用 jsonFile
        _jsonFilePath =
            arguments['jsonFile'] ?? 'assets/data/kiki_zhiwuyuan.json';
        _imagePath = _getImagePathFromJsonFile(_jsonFilePath);
      }

      // 接收图片列表
      if (arguments['images'] != null && arguments['images'] is List) {
        final imagesList = arguments['images'] as List;
        // 只有当列表不为空且第一个元素是 ImageItem 时才转换
        if (imagesList.isNotEmpty && imagesList.first is ImageItem) {
          _imagesList = imagesList.cast<ImageItem>();
        } else {
          _imagesList = [];
        }
      }
    } else {
      // 默认值
      _jsonFilePath = 'assets/data/kiki_zhiwuyuan.json';
      _imagePath = 'assets/images/kiki_zhiwuyuan.jpg';
    }

    AppLogger.debug('JSON File = $_jsonFilePath');
    AppLogger.debug('Image Path = $_imagePath');
    AppLogger.debug('Has Scene = ${_scene != null}');
    AppLogger.debug('Current ImageItem = ${_currentImageItem?.title}');
    AppLogger.debug('Images count = ${_imagesList.length}');
  }

  String _resolveSceneImagePath(Map scene) {
    final interactiveImage =
        (scene['interactive_image'] ?? scene['interactiveImage'] ?? '')
            .toString();
    final coverImage =
        (scene['cover_image'] ?? scene['coverImage'] ?? '').toString();
    final resolved =
        interactiveImage.trim().isNotEmpty ? interactiveImage : coverImage;
    return resolved.trim();
  }

  /// 根据 JSON 文件名推断图片路径
  String _getImagePathFromJsonFile(String jsonFile) {
    // 如果是远程 URL，直接返回
    if (jsonFile.startsWith('http://') || jsonFile.startsWith('https://')) {
      // 从 URL 推断对应的图片 URL
      if (jsonFile.contains('dongwuyuan')) {
        return jsonFile
            .replaceAll(RegExp(r'\.json$'), '.jpg')
            .replaceAll('/kiki_dongwuyuan.json', '/kiki_dongwuyuan.jpg');
      } else if (jsonFile.contains('zhiwuyuan')) {
        return jsonFile
            .replaceAll(RegExp(r'\.json$'), '.jpg')
            .replaceAll('/kiki_zhiwuyuan.json', '/kiki_zhiwuyuan.jpg');
      }
      return jsonFile.replaceAll(RegExp(r'\.json$'), '.jpg');
    }

    // 本地资源路径
    if (jsonFile.contains('toy')) {
      return 'assets/images/toy/kiki_toy.png';
    } else if (jsonFile.contains('dongwuyuan')) {
      return 'assets/images/kiki_dongwuyuan.jpg';
    } else if (jsonFile.contains('zhiwuyuan')) {
      return 'assets/images/kiki_zhiwuyuan.jpg';
    }
    return 'assets/images/kiki_zhiwuyuan.jpg'; // 默认值
  }

  /// Getter：获取当前图片路径
  String get imagePath => _imagePath;

  /// Getter：获取当前 JSON 文件路径
  String get jsonPath => _jsonFilePath;

  /// Getter：获取当前 ImageItem
  ImageItem? get currentImageItem => _currentImageItem;

  /// Getter：获取图片列表
  List<ImageItem> get imagesList => _imagesList;

  @override
  void onInit() {
    super.onInit();
    _sessionStartTime = DateTime.now();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      AppLogger.debug('Initialization started');
      errorMessage.value = null;
      loadingProgress.value = 0.1;

      // 只等待数据加载（最多 15 秒）
      await Future.wait([
        _loadRegions(),
        _loadImageDimensions(),
        _loadLearningProgress(), // 加载学习进度
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.warning('Data loading timed out after 15 seconds');
          throw TimeoutException('Loading timed out');
        },
      ).catchError((e) {
        AppLogger.error('Data loading failed', e);
        return <void>[];
      });

      AppLogger.debug('Initialization completed');
      loadingProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 200));
      isLoaded.value = true;
      AppLogger.info('Initialization completed successfully');
    } catch (e) {
      AppLogger.error('Initialization error', e);
      errorMessage.value = "Failed to initialize: $e";
      isLoaded.value = true; // Set to loaded to show error UI
    }
  }

  Future<void> _loadRegions() async {
    try {
      List<InteractiveRegion> loadedRegions = [];

      // 优先从 scene 对象的 items_data 中加载数据（新数据结构）
      if (_scene != null) {
        AppLogger.info('Loading regions from scene object (embedded data)');
        try {
          List<dynamic>? itemsData;

          // 尝试从 scene 对象中提取 items_data
          if (_scene is Map) {
            itemsData = _scene['items_data'] ?? _scene['itemsData'];
            AppLogger.debug(
                'Scene is Map, items_data: ${itemsData?.length ?? 0} items');
          } else {
            // 如果是 Scene 对象，直接从 arguments 中获取（因为 Scene 类没有 items_data 属性）
            final arguments = Get.arguments;
            if (arguments != null && arguments is Map) {
              // 从原始 API 响应中获取 items_data
              final sceneData = arguments['scene'];
              if (sceneData is Map) {
                itemsData = sceneData['items_data'] ?? sceneData['itemsData'];
                AppLogger.debug(
                    'Extracted items_data from arguments Map: ${itemsData?.length ?? 0} items');
              }
            }
          }

          if (itemsData != null && itemsData.isNotEmpty) {
            loadedRegions = InteractiveRegion.parseItemsData(itemsData);
            AppLogger.info(
                'Loaded ${loadedRegions.length} regions from scene.items_data');
          } else {
            AppLogger.warning('Scene object has no items_data or it is empty');
          }
        } catch (e) {
          AppLogger.error('Error loading regions from scene object', e);
        }
      }

      // 如果从 scene 对象加载失败，且有 jsonFile 路径，则从 JSON 文件加载（兼容旧数据结构）
      if (loadedRegions.isEmpty && _jsonFilePath.isNotEmpty) {
        AppLogger.debug('Loading regions from JSON file: $_jsonFilePath');
        loadedRegions = await _repository.loadRegions(jsonPath: _jsonFilePath);
      }

      if (loadedRegions.isNotEmpty) {
        regions.assignAll(loadedRegions);
        AppLogger.info('Successfully loaded ${loadedRegions.length} regions');
      } else {
        AppLogger.warning('No regions loaded');
      }

      loadingProgress.value = 0.7;
    } catch (e) {
      AppLogger.error('Error loading regions', e);
      errorMessage.value = "Failed to load regions: $e";
    }
  }

  Future<void> _loadImageDimensions() async {
    try {
      // 优先从 scene 数据中直接读取嵌入的像素尺寸（跳过图片解码，速度最快）
      if (_scene != null) {
        double? embeddedWidth;
        double? embeddedHeight;

        if (_scene is Map) {
          final w = _scene['image_width'];
          final h = _scene['image_height'];
          if (w != null && h != null) {
            embeddedWidth = (w as num).toDouble();
            embeddedHeight = (h as num).toDouble();
          }
        }

        if (embeddedWidth != null && embeddedHeight != null) {
          AppLogger.info(
              'Image dimensions from scene data: $embeddedWidth x $embeddedHeight (no decode needed)');
          imageWidth.value = embeddedWidth;
          imageHeight.value = embeddedHeight;
          loadingProgress.value = 0.9;
          return;
        }
      }

      // 降级：解码图片获取尺寸（首次访问较慢，但结果会被缓存）
      AppLogger.debug('Loading image from: $_imagePath');

      final dimensions = await _repository.loadImageDimensions(_imagePath);
      final width = dimensions['width'] ?? 1920.0;
      final height = dimensions['height'] ?? 1080.0;

      AppLogger.info('Image dimensions: $width x $height');
      imageWidth.value = width;
      imageHeight.value = height;
      loadingProgress.value = 0.9;
    } catch (e) {
      AppLogger.error('Error loading image dimensions', e);
      errorMessage.value = "Failed to load image: $e";
      // Set default dimensions to allow view to render
      imageWidth.value = 1920.0;
      imageHeight.value = 1080.0;
    }
  }

  bool _isSpeaking = false;
  final isSpeaking = false.obs;
  Timer? _strokeStartTimer;
  static const Duration _strokeStartDelay = Duration(milliseconds: 140);

  // 空白区域点击检测
  int _blankAreaClickCount = 0;
  Timer? _blankAreaClickTimer;
  static const Duration _blankAreaClickTimeout = Duration(seconds: 2);

  // 星星奖励系统
  final starsEarned = 0.obs; // 当前获得的星星数（0-3）
  final isSceneCompleted = false.obs; // 场景是否已完成
  final Set<String> _learnedRegionIds = {}; // 已学习的区域ID集合
  final List<Map<String, dynamic>> _sessionLearnedRegions = []; // 本次会话学习的区域
  DateTime? _sessionStartTime; // 会话开始时间
  final showStarAnimation = false.obs; // 是否显示星星动画
  final latestStarCount = 0.obs; // 最新获得的星星数（用于触发动画）

  /// Speak a region's audio (Chinese and English)
  Future<void> speakRegion(InteractiveRegion region) async {
    AppLogger.info(
        '🔊 Speaking region: ${region.text} / ${region.textEnglish}');

    // 点击图片自动播放：使用 fast 速度
    animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
      StrokePlayMode.imageClick,
    );

    // Update UI immediately for instant visual feedback
    activeRegion.value = region;
    _scheduleCharacterAnimation(region.text);

    // 播放音频
    await _interruptAndSpeak(() async {
      await _audioPlayback.playRegion(region);
    });

    // 播放完成后，记录学习进度（防止快速点击刷进度）
    _recordLearningProgress(region);
  }

  /// Speak only the pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _audioPlayback.playPinyin(region);
    });
  }

  /// Speak only English word for the active region.
  Future<void> speakEnglishWord(InteractiveRegion region) async {
    final english = region.textEnglish.trim();
    if (english.isEmpty) return;

    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _audioPlayback.playEnglishWord(region);
    });
  }

  /// Speak Chinese phrase only (used by the "点击朗读" button).
  /// Note: Does not restart character animation to avoid interrupting user's current progress.
  Future<void> speakChinesePhrase(InteractiveRegion region) async {
    final chinese = region.text.trim();
    if (chinese.isEmpty) return;

    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _audioPlayback.playChinesePhrase(region);
    });
  }

  /// Speak a single Chinese character and focus the character cell.
  Future<void> speakChineseChar(
    InteractiveRegion region,
    int charIndex,
    String character,
  ) async {
    final trimmed = character.trim();
    if (trimmed.isEmpty) return;

    // 点击单个字：使用 normal 速度
    animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
      StrokePlayMode.characterClick,
    );

    activeRegion.value = region;
    _focusCharacter(region.text, charIndex);
    await _interruptAndSpeak(() async {
      await _audioPlayback.playChineseChar(trimmed);
    });
  }

  /// Debug info
  String getDiagnostics() {
    return '''
Interactive Image Diagnostics:
- isLoaded: ${isLoaded.value}
- imageWidth: ${imageWidth.value}
- imageHeight: ${imageHeight.value}
- regions count: ${regions.length}
- loadingProgress: ${(loadingProgress.value * 100).toStringAsFixed(1)}%
- error: ${errorMessage.value ?? 'none'}
    ''';
  }

  @override
  void onClose() {
    _strokeStartTimer?.cancel();
    _blankAreaClickTimer?.cancel();
    _audioPlayback.dispose();
    super.onClose();
  }

  void initializeCharacterProgress(String text) {
    if (_lastInitializedText == text &&
        totalCharCount.value == _countCharacters(text)) {
      return;
    }
    _setupCharacterProgress(text);
  }

  void onCharacterAnimationComplete(int index) {
    if (index != currentCharIndex.value) {
      return;
    }

    if (_singleCharacterMode) {
      currentCharIndex.value = -1;
      return;
    }

    final total = totalCharCount.value;
    if (index >= total - 1) {
      currentCharIndex.value = -1;
      return;
    }

    visibleCharCount.value = (index + 2).clamp(0, total);
    currentCharIndex.value = index + 1;
  }

  void _restartCharacterAnimation(String text) {
    _singleCharacterMode = false;
    _setupCharacterProgress(text, force: true);
  }

  void _focusCharacter(String text, int charIndex) {
    final chars =
        text.split('').where((char) => char.trim().isNotEmpty).toList();
    if (chars.isEmpty) {
      currentCharIndex.value = -1;
      visibleCharCount.value = 0;
      totalCharCount.value = 0;
      return;
    }

    final safeIndex = charIndex.clamp(0, chars.length - 1);
    _lastInitializedText = text;
    _singleCharacterMode = true;
    totalCharCount.value = chars.length;
    visibleCharCount.value = chars.length;
    currentCharIndex.value = safeIndex;
  }

  Future<void> _interruptAndSpeak(Future<void> Function() action) async {
    _strokeStartTimer?.cancel();
    if (_isSpeaking) {
      await _audioPlayback.stop();
    }
    _isSpeaking = true;
    isSpeaking.value = true;
    try {
      await action();
      if (_hasTtsPlaybackError) {
        errorMessage.value = null;
        _hasTtsPlaybackError = false;
      }
    } catch (e) {
      final message = _buildTtsPlaybackErrorMessage(e);
      errorMessage.value = message;
      _hasTtsPlaybackError = true;
      AppLogger.error('TTS action failed', e);
    } finally {
      _isSpeaking = false;
      isSpeaking.value = false;
    }
  }

  String _buildTtsPlaybackErrorMessage(Object error) {
    final languageCode =
        (Get.locale ?? Get.deviceLocale)?.languageCode.toLowerCase();
    if (languageCode == 'zh') {
      return '语音播放失败，请检查模型文件与音频输出设备。\n$error';
    }
    return 'TTS playback failed. Please check model files and audio output device.\n$error';
  }

  void _setupCharacterProgress(String text, {bool force = false}) {
    final total = _countCharacters(text);
    if (!force &&
        _lastInitializedText == text &&
        totalCharCount.value == total) {
      return;
    }

    _lastInitializedText = text;
    _singleCharacterMode = false;
    totalCharCount.value = total;
    if (total <= 0) {
      visibleCharCount.value = 0;
      currentCharIndex.value = -1;
    } else {
      visibleCharCount.value = 1;
      currentCharIndex.value = 0;
    }
  }

  int _countCharacters(String text) {
    return text.split('').where((char) => char.trim().isNotEmpty).length;
  }

  void _scheduleCharacterAnimation(String text) {
    _strokeStartTimer?.cancel();
    _strokeStartTimer = Timer(_strokeStartDelay, () {
      if (isClosed) return;
      _restartCharacterAnimation(text);
    });
  }

  /// 处理空白区域点击
  void onBlankAreaClicked() {
    _blankAreaClickCount++;
    AppLogger.info('空白区域点击次数: $_blankAreaClickCount');

    // 重置计时器
    _blankAreaClickTimer?.cancel();
    _blankAreaClickTimer = Timer(_blankAreaClickTimeout, () {
      // 超时后重置计数
      _blankAreaClickCount = 0;
    });

    // 如果连续点击3次，播放提示音
    if (_blankAreaClickCount >= 3) {
      _playBlankAreaHint();
      _blankAreaClickCount = 0;
      _blankAreaClickTimer?.cancel();
    }
  }

  /// 播放空白区域提示音
  Future<void> _playBlankAreaHint() async {
    AppLogger.info('🔊 播放空白区域提示音');
    await _interruptAndSpeak(() async {
      await _audioPlayback.playAudioFile('assets/audio/blank_area_hint.mp3');
    });
  }

  /// 记录学习进度并检查星星奖励
  void _recordLearningProgress(InteractiveRegion region) {
    // 如果场景已完成，不再记录进度
    if (isSceneCompleted.value) {
      AppLogger.debug('场景已完成，不记录进度');
      return;
    }

    // 生成区域唯一ID（使用文本作为ID）
    final regionId = region.text;

    // 检查是否已经学过这个区域
    if (_learnedRegionIds.contains(regionId)) {
      AppLogger.debug('区域 $regionId 已学过，不重复记录');
      return;
    }

    // 记录到已学习集合
    _learnedRegionIds.add(regionId);
    _sessionLearnedRegions.add({
      'region_id': regionId,
      'region_text': region.text,
      'region_text_english': region.textEnglish,
      'learned_at': DateTime.now().toIso8601String(),
    });

    AppLogger.info(
        '✅ 记录学习进度: $regionId (已学习 ${_learnedRegionIds.length}/${regions.length})');

    // 检查是否触发新星星
    _checkStarReward();
  }

  /// 检查并触发星星奖励
  void _checkStarReward() {
    final totalRegions = regions.length;
    final learnedCount = _learnedRegionIds.length;

    if (totalRegions == 0) return;

    // 计算应该获得的星星数（1/3、2/3、3/3进度）
    int newStars = _calculateStars(learnedCount, totalRegions);

    AppLogger.debug(
        '进度计算: $learnedCount/$totalRegions → 应得星星: $newStars, 当前星星: ${starsEarned.value}');

    // 如果是第3颗星，需要检查时间条件
    if (newStars == 3 && starsEarned.value < 3) {
      final studyTime = _getSessionDuration();
      AppLogger.info('检查第3颗星时间条件: $studyTime秒 (需要>=30秒)');

      if (studyTime < 30) {
        // 时间不够，只给2颗星
        newStars = 2;
        AppLogger.warning('学习时间不足，暂不给第3颗星');
      } else {
        // 时间足够，标记场景完成
        isSceneCompleted.value = true;
        AppLogger.info('🎉 场景完成！');
      }
    }

    // 触发星星奖励动画
    if (newStars > starsEarned.value) {
      final earnedNow = newStars;
      starsEarned.value = newStars;
      latestStarCount.value = earnedNow;

      AppLogger.info('🌟 触发星星奖励: 第$earnedNow颗星');
      _playStarRewardAnimation(earnedNow);
    }
  }

  /// 计算应得的星星数
  int _calculateStars(int learned, int total) {
    if (total == 0) return 0;

    double progress = learned / total;

    if (progress >= 1.0) return 3; // 100%
    if (progress >= 0.67) return 2; // 67%
    if (progress >= 0.33) return 1; // 33%
    return 0;
  }

  /// 获取会话持续时长（秒）
  int _getSessionDuration() {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  /// 播放星星奖励动画和音效
  Future<void> _playStarRewardAnimation(int starNumber) async {
    showStarAnimation.value = true;

    // 根据星星数播放不同音效
    String audioFile;
    switch (starNumber) {
      case 1:
        audioFile = 'assets/audio/star_1.mp3';
        break;
      case 2:
        audioFile = 'assets/audio/star_2.mp3';
        break;
      case 3:
        audioFile = 'assets/audio/star_3_complete.mp3';
        break;
      default:
        return;
    }

    // 播放音效
    try {
      await _audioPlayback.playAudioFile(audioFile);
    } catch (e) {
      AppLogger.error('播放星星音效失败', e);
    }

    // 动画结束
    await Future.delayed(const Duration(seconds: 1));
    showStarAnimation.value = false;
  }

  /// 加载学习进度
  Future<void> _loadLearningProgress() async {
    try {
      // 获取当前用户ID（TODO: 从用户服务获取）
      const currentUserId = 'guest_user'; // 临时使用guest
      final sceneId = _getSceneId();

      if (sceneId.isEmpty) {
        AppLogger.warning('场景ID为空，跳过加载进度');
        return;
      }

      // 先从本地加载
      SceneProgress? progress = await _progressService.loadLocalProgress(
        currentUserId,
        sceneId,
      );

      // 如果本地没有，尝试从服务器获取（可选）
      progress ??= await _progressService.fetchProgressFromServer(
        currentUserId,
        sceneId,
      );

      // 恢复进度状态
      if (progress != null) {
        _learnedRegionIds.addAll(progress.learnedRegions);
        starsEarned.value = progress.starsEarned;
        isSceneCompleted.value = progress.isCompleted;

        AppLogger.info(
          '恢复学习进度: 已学${progress.learnedCount}/${progress.totalRegions}, '
          '星星${progress.starsEarned}, 完成=${progress.isCompleted}',
        );
      }
    } catch (e) {
      AppLogger.error('加载学习进度失败', e);
    }
  }

  /// 保存学习进度（退出时调用）
  Future<bool> saveProgress() async {
    try {
      // 如果本次没有新学习内容，不保存
      if (_sessionLearnedRegions.isEmpty) {
        AppLogger.debug('本次无新学习内容，跳过保存');
        return true;
      }

      const currentUserId = 'guest_user';
      final sceneId = _getSceneId();
      final studyTime = _getSessionDuration();

      if (sceneId.isEmpty) {
        AppLogger.warning('场景ID为空，无法保存进度');
        return false;
      }

      // 构建进度对象
      final progress = SceneProgress(
        userId: currentUserId,
        sceneId: sceneId,
        totalRegions: regions.length,
        learnedRegions: _learnedRegionIds.toList(),
        learnedCount: _learnedRegionIds.length,
        starsEarned: starsEarned.value,
        isCompleted: isSceneCompleted.value,
        lastLearnedAt: DateTime.now(),
        totalStudyTime: studyTime,
      );

      // 保存到本地
      await _progressService.saveLocalProgress(progress);

      // 尝试提交到服务器
      bool serverSuccess = await _progressService.submitProgressToServer(
        userId: currentUserId,
        sceneId: sceneId,
        learnedRegions: _sessionLearnedRegions,
        starsEarned: starsEarned.value,
        isCompleted: isSceneCompleted.value,
        studyTime: studyTime,
      );

      if (serverSuccess) {
        AppLogger.info('✅ 学习进度保存成功（本地+服务器）');
      } else {
        AppLogger.warning('⚠️ 学习进度已保存到本地，服务器同步失败');
      }

      return true;
    } catch (e) {
      AppLogger.error('保存学习进度失败', e);
      return false;
    }
  }

  /// 获取场景ID
  String _getSceneId() {
    // 优先使用scene对象的ID
    if (_scene != null) {
      if (_scene is Map) {
        return _scene['id']?.toString() ?? _scene['scene_id']?.toString() ?? '';
      }
    }

    // 降级：从JSON文件路径推断
    if (_jsonFilePath.isNotEmpty) {
      // 提取文件名作为场景ID（如：kiki_zhiwuyuan.json → kiki_zhiwuyuan）
      final fileName = _jsonFilePath.split('/').last.replaceAll('.json', '');
      return fileName;
    }

    return '';
  }
}
