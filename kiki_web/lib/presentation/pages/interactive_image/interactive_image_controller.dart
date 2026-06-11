import 'dart:async';
import 'package:get/get.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/network_client.dart';
import '../../../data/models/image_item.dart';
import '../../../domain/entities/interactive_region.dart';
import '../../../data/repositories/interactive_image/i_interactive_image_repository.dart';
import '../../../data/repositories/interactive_image/interactive_image_repository_impl.dart';
import '../../../core/speech/audio_playback_component.dart';
import '../../../data/services/learning/reward_service.dart';
import '../../widgets/stroke_animation/stroke_speed_config.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';

/// 星星奖励事件：通知 Page 层触发飞翔动画
class StarRewardEvent {
  /// 新点亮的星星索引（0-based），对应右上角第 starIndex+1 颗星
  final int starIndex;
  StarRewardEvent(this.starIndex);
}

class InteractiveImageController extends GetxController {
  late final IInteractiveImageRepository _repository;
  late final AudioPlaybackComponent _audioPlayback;
  late final RewardService _rewardService;

  // ─── 基础状态 ─────────────────────────────────────────────────
  final regions = <InteractiveRegion>[].obs;
  final imageWidth = 1.0.obs;
  final imageHeight = 1.0.obs;
  final isLoaded = false.obs;
  final errorMessage = RxnString();
  final loadingProgress = 0.0.obs;

  // ─── UI 交互状态 ──────────────────────────────────────────────
  final isAutoPlay = false.obs;
  final activeRegion = Rxn<InteractiveRegion>();
  final currentCharIndex = (-1).obs;
  final visibleCharCount = 0.obs;
  final totalCharCount = 0.obs;
  final animationSpeed = 2.0.obs;
  String? _lastInitializedText;
  bool _singleCharacterMode = false;
  bool _hasTtsPlaybackError = false;

  // ─── 星星奖励状态 ─────────────────────────────────────────────
  /// 已获得的星星数（0~3）
  final starsEarned = 0.obs;

  /// 实际被授予的星星数（以防在UI上立即亮起，等飞行动画落地后再给 starsEarned 赋值）
  int _starsAwarded = 0;

  /// 飞翔动画事件流：Page 层监听后触发动画
  final starRewardEvent = Rxn<StarRewardEvent>();

  /// 已学词 ID 集合（去重）
  final Set<String> _learnedRegionIds = {};

  /// 会话本次新学词（用于提交服务器）
  final List<Map<String, dynamic>> _sessionLearnedRegions = [];

  /// 会话开始时间（用于第 3 颗星时间门槛 ≥30 秒）
  DateTime? _sessionStartTime;

  // ─── 路由参数 ─────────────────────────────────────────────────
  late String _jsonFilePath;
  late String _imagePath;
  ImageItem? _currentImageItem;
  List<ImageItem> _imagesList = [];
  dynamic _scene;

  // ─── 用户 ID（从 AuthController 获取）─────────────────
  String get _userId {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn) {
        return authController.currentUser?.id ?? '';
      }
    } catch (e) {
      AppLogger.warning('Failed to find AuthController', e);
    }
    return '';
  }

  /// 检查当前是否应与服务器同步（已登录且持有有效 Token）
  bool get _isServerSyncEnabled {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) return false;

      final authInterceptor = NetworkClient.instance.getInterceptor<AuthInterceptor>();
      return authInterceptor?.hasToken ?? false;
    } catch (_) {}
    return false;
  }

  InteractiveImageController({
    IInteractiveImageRepository? repository,
    AudioPlaybackComponent? audioPlayback,
    RewardService? rewardService,
  }) {
    _repository = repository ?? InteractiveImageRepositoryImpl();
    _audioPlayback = audioPlayback ?? AudioPlaybackComponent();
    _rewardService = rewardService ?? RewardService(httpClient: NetworkClient.instance.httpClient);
    _getParametersFromRoute();
  }

  // ─── 路由参数解析 ─────────────────────────────────────────────
  void _getParametersFromRoute() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      if (arguments['scene'] != null) {
        _scene = arguments['scene'];
        if (_scene is Map) {
          _imagePath = _resolveSceneImagePath(_scene);
        } else {
          try {
            _imagePath = _scene.interactiveImage ?? '';
          } catch (e) {
            AppLogger.warning('Failed to extract image path from scene object', e);
            _imagePath = '';
          }
        }
        _jsonFilePath = arguments['jsonFile'] ?? '';
      } else if (arguments['imageItem'] != null &&
          arguments['imageItem'] is ImageItem) {
        _currentImageItem = arguments['imageItem'] as ImageItem;
        _jsonFilePath = _currentImageItem!.jsonFile;
        _imagePath = _currentImageItem!.imagePath;
      } else {
        _jsonFilePath =
            arguments['jsonFile'] ?? 'assets/data/kiki_zhiwuyuan.json';
        _imagePath = _getImagePathFromJsonFile(_jsonFilePath);
      }
      if (arguments['images'] != null && arguments['images'] is List) {
        final imagesList = arguments['images'] as List;
        if (imagesList.isNotEmpty && imagesList.first is ImageItem) {
          _imagesList = imagesList.cast<ImageItem>();
        } else {
          _imagesList = [];
        }
      }
    } else {
      _jsonFilePath = 'assets/data/kiki_zhiwuyuan.json';
      _imagePath = 'assets/images/kiki_zhiwuyuan.jpg';
    }
    AppLogger.debug('JSON File = $_jsonFilePath');
    AppLogger.debug('Image Path = $_imagePath');
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

  String _getImagePathFromJsonFile(String jsonFile) {
    if (jsonFile.startsWith('http://') || jsonFile.startsWith('https://')) {
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
    if (jsonFile.contains('toy')) return 'assets/images/toy/kiki_toy.png';
    if (jsonFile.contains('dongwuyuan')) {
      return 'assets/images/kiki_dongwuyuan.jpg';
    }
    if (jsonFile.contains('zhiwuyuan')) {
      return 'assets/images/kiki_zhiwuyuan.jpg';
    }
    return 'assets/images/kiki_zhiwuyuan.jpg';
  }

  // ─── Getters ──────────────────────────────────────────────────
  String get imagePath => _imagePath;
  String get jsonPath => _jsonFilePath;
  ImageItem? get currentImageItem => _currentImageItem;
  List<ImageItem> get imagesList => _imagesList;

  /// 过滤掉标题、副标题等非词卡区域，仅保留真实的学习词语区域
  List<InteractiveRegion> get vocabularyRegions {
    return regions.where((r) {
      final idLower = r.id.toLowerCase();
      return !idLower.contains('title') && !idLower.contains('subtitle');
    }).toList();
  }

  // ─── 初始化 ───────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  Future<void> _initialize() async {
    try {
      errorMessage.value = null;
      loadingProgress.value = 0.1;
      _sessionStartTime = DateTime.now();

      // 重置状态以支持控制器复用
      regions.clear();
      activeRegion.value = null;
      currentCharIndex.value = -1;
      visibleCharCount.value = 0;
      totalCharCount.value = 0;
      _lastInitializedText = null;
      _singleCharacterMode = false;
      _hasTtsPlaybackError = false;
      starsEarned.value = 0;
      _starsAwarded = 0;
      _learnedRegionIds.clear();
      _sessionLearnedRegions.clear();
      isLoaded.value = false;

      await Future.wait([
        _loadRegions(),
        _loadImageDimensions(),
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

      // 加载完成后恢复本地与服务器进度
      await _loadLocalProgress();

      loadingProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 200));
      isLoaded.value = true;
    } catch (e) {
      AppLogger.error('Initialization error', e);
      errorMessage.value = 'Failed to initialize: $e';
      isLoaded.value = true;
    }
  }

  /// 外部（如 Page）在进入时调用，确保如果控制器实例被复用，也能加载最新路由参数的数据
  void refreshArguments() {
    final oldJson = _jsonFilePath;
    final oldSceneId = _getSceneId();
    _getParametersFromRoute();
    if (_jsonFilePath != oldJson || _getSceneId() != oldSceneId) {
      AppLogger.info('Scene arguments changed, re-initializing: $oldSceneId -> ${_getSceneId()}');
      _initialize();
    }
  }
  Future<void> _loadRegions() async {
    try {
      List<InteractiveRegion> loadedRegions = [];
      if (_scene != null) {
        List<dynamic>? itemsData;
        if (_scene is Map) {
          itemsData = _scene['items_data'] ?? _scene['itemsData'];
        } else {
          final arguments = Get.arguments;
          if (arguments != null && arguments is Map) {
            final sceneData = arguments['scene'];
            if (sceneData is Map) {
              itemsData = sceneData['items_data'] ?? sceneData['itemsData'];
            }
          }
        }
        if (itemsData != null && itemsData.isNotEmpty) {
          loadedRegions = InteractiveRegion.parseItemsData(itemsData);
        }
      }
      if (loadedRegions.isEmpty && _jsonFilePath.isNotEmpty) {
        loadedRegions =
            await _repository.loadRegions(jsonPath: _jsonFilePath);
      }
      if (loadedRegions.isNotEmpty) {
        regions.assignAll(loadedRegions);
      }
      loadingProgress.value = 0.7;
    } catch (e) {
      AppLogger.error('Error loading regions', e);
      errorMessage.value = 'Failed to load regions: $e';
    }
  }

  Future<void> _loadImageDimensions() async {
    try {
      if (_scene != null && _scene is Map) {
        final w = _scene['image_width'];
        final h = _scene['image_height'];
        if (w != null && h != null) {
          imageWidth.value = (w as num).toDouble();
          imageHeight.value = (h as num).toDouble();
          loadingProgress.value = 0.9;
          return;
        }
      }
      final dimensions = await _repository.loadImageDimensions(_imagePath);
      imageWidth.value = dimensions['width'] ?? 1920.0;
      imageHeight.value = dimensions['height'] ?? 1080.0;
      loadingProgress.value = 0.9;
    } catch (e) {
      AppLogger.error('Error loading image dimensions', e);
      errorMessage.value = 'Failed to load image: $e';
      imageWidth.value = 1920.0;
      imageHeight.value = 1080.0;
    }
  }

  // ─── 学习进度恢复 ─────────────────────────────────────────────
  /// 从本地缓存与服务器恢复进度
  Future<void> _loadLocalProgress() async {
    try {
      final sceneId = _getSceneId();
      if (sceneId.isEmpty) return;

      // 1. 从本地加载已学习的词 IDs
      final savedIds =
          await _rewardService.loadLearnedRegionIds(_userId, sceneId);
      _learnedRegionIds.addAll(savedIds);

      // 2. 尝试从服务器拉取最新进度并合并
      if (_isServerSyncEnabled) {
        try {
          final serverProgress =
              await _rewardService.fetchProgressFromServer(_userId, sceneId);
          if (serverProgress != null) {
            final serverIds = serverProgress.learnedRegions;
            if (serverIds.isNotEmpty) {
              _learnedRegionIds.addAll(serverIds);
              // 将合并后的最新进度更新到本地
              await _rewardService.saveLearnedRegionIds(
                _userId,
                sceneId,
                Set.from(_learnedRegionIds),
              );
            }
          }
        } catch (e) {
          AppLogger.warning('从服务器同步进度失败，仅使用本地缓存', e);
        }
      }

      // 3. 根据已学数量重新计算星星数（比例制）
      final total = vocabularyRegions.map((r) => r.text).toSet().length;
      if (total > 0 && _learnedRegionIds.isNotEmpty) {
        final loadedStars =
            _rewardService.calculateStars(_learnedRegionIds.length, total);
        starsEarned.value = loadedStars;
        _starsAwarded = loadedStars;
        AppLogger.info(
            '恢复进度: ${_learnedRegionIds.length}/$total 词, $loadedStars 颗星');
      }
    } catch (e) {
      AppLogger.error('恢复本地与服务器进度失败', e);
    }
  }
  // ─── 音频播放 ─────────────────────────────────────────────────
  bool _isSpeaking = false;
  final isSpeaking = false.obs;
  Timer? _strokeStartTimer;
  static const Duration _strokeStartDelay = Duration(milliseconds: 140);

  int _blankAreaClickCount = 0;
  Timer? _blankAreaClickTimer;
  static const Duration _blankAreaClickTimeout = Duration(seconds: 2);

  /// 点击区域：播放音频 + 记录学习进度
  Future<void> speakRegion(InteractiveRegion region) async {
    AppLogger.info('🔊 Speaking region: ${region.text}');

    animationSpeed.value =
        StrokeSpeedConfig.getSpeedForMode(StrokePlayMode.imageClick);
    activeRegion.value = region;
    _scheduleCharacterAnimation(region.text);

    await _interruptAndSpeak(() async {
      await _audioPlayback.playRegion(region);
    });

    // 音频播放结束后记录进度（防止快速点击刷进度）
    _recordLearningProgress(region);
  }

  void selectRegionForDisplay(InteractiveRegion region) {
    activeRegion.value = region;
    _scheduleCharacterAnimation(region.text);
  }

  Future<void> speakPinyin(InteractiveRegion region) async {
    activeRegion.value = region;
    await _interruptAndSpeak(
        () async => _audioPlayback.playPinyin(region));
  }

  Future<void> speakEnglishWord(InteractiveRegion region) async {
    if (region.textEnglish.trim().isEmpty) return;
    activeRegion.value = region;
    await _interruptAndSpeak(
        () async => _audioPlayback.playEnglishWord(region));
  }

  Future<void> speakChinesePhrase(InteractiveRegion region) async {
    if (region.text.trim().isEmpty) return;
    activeRegion.value = region;
    await _interruptAndSpeak(
        () async => _audioPlayback.playChinesePhrase(region));
  }

  Future<void> speakChineseChar(
    InteractiveRegion region,
    int charIndex,
    String character,
  ) async {
    final trimmed = character.trim();
    if (trimmed.isEmpty) return;
    animationSpeed.value =
        StrokeSpeedConfig.getSpeedForMode(StrokePlayMode.characterClick);
    activeRegion.value = region;
    _focusCharacter(region.text, charIndex);
    await _interruptAndSpeak(
        () async => _audioPlayback.playChineseChar(trimmed));
  }

  // ─── 星星奖励逻辑 ─────────────────────────────────────────────

  /// 记录学习进度，并在满足门槛时触发星星奖励
  void _recordLearningProgress(InteractiveRegion region) {
    // 标题和副标题不作为词汇卡片记录进度
    if (region.id.toLowerCase().contains('title') ||
        region.id.toLowerCase().contains('subtitle')) {
      AppLogger.debug('点击的是标题或副标题，跳过进度记录: ${region.text}');
      return;
    }

    final regionId = region.text;
    final total = vocabularyRegions.map((r) => r.text).toSet().length;

    // 去重：已学过的词不再计入
    if (_learnedRegionIds.contains(regionId)) {
      AppLogger.debug('区域已学过，跳过: $regionId');
      _checkStarReward(); // 允许重新检查以防之前因为时间门槛（<30秒）未获得满星，而现在时间已满足
      return;
    }

    _learnedRegionIds.add(regionId);
    _sessionLearnedRegions.add({
      'region_id': regionId,
      'region_text': region.text,
      'learned_at': DateTime.now().toIso8601String(),
    });

    final allVocab = vocabularyRegions.map((r) => r.text).toSet();
    AppLogger.info(
        '✅ 记录学习: $regionId (${_learnedRegionIds.length}/$total) | 已学: $_learnedRegionIds | 总表: $allVocab');

    _checkStarReward();
  }

  /// 检查是否触发新星星奖励（30% / 60% / 100%）
  void _checkStarReward() {
    final total = vocabularyRegions.map((r) => r.text).toSet().length;
    if (total == 0) return;

    final learned = _learnedRegionIds.length;
    final targetStars = _rewardService.calculateStars(learned, total);

    if (targetStars > _starsAwarded) {
      final oldStarsAwarded = _starsAwarded;
      _starsAwarded = targetStars;

      // 依次发射每一个新获得的星星（支持连发动画）
      for (int i = oldStarsAwarded; i < targetStars; i++) {
        AppLogger.info('🌟 触发星星奖励：第 ${i + 1} 颗星');
        starRewardEvent.value = StarRewardEvent(i);
      }

      // 保存进度到本地（异步，不阻塞 UI）
      _saveLocalProgressAsync();
    }
  }

  /// 异步保存本地进度并提交服务器（不阻塞 UI）
  void _saveLocalProgressAsync() {
    final sceneId = _getSceneId();
    if (sceneId.isEmpty) return;

    _rewardService
        .saveLearnedRegionIds(_userId, sceneId, Set.from(_learnedRegionIds))
        .then((_) {
      if (!_isServerSyncEnabled) return;
      final studyTime = DateTime.now()
          .difference(_sessionStartTime ?? DateTime.now())
          .inSeconds;
      _rewardService.submitProgressToServer(
        userId: _userId,
        sceneId: sceneId,
        learnedRegionIds: Set.from(_learnedRegionIds),
        starsEarned: _starsAwarded,
        isCompleted: _starsAwarded >= 3,
        studyTimeSeconds: studyTime,
      );
    }).catchError((e) {
      AppLogger.error('保存本地进度失败', e);
    });
  }

  /// 退出页面时调用：保存本地 + 提交服务器
  Future<bool> saveProgress() async {
    try {
      final sceneId = _getSceneId();
      if (sceneId.isEmpty || _sessionLearnedRegions.isEmpty) {
        AppLogger.debug('无新学习内容，跳过保存');
        return true;
      }

      final studyTime = DateTime.now()
          .difference(_sessionStartTime ?? DateTime.now())
          .inSeconds;

      // 1. 保存本地
      await _rewardService.saveLearnedRegionIds(
        _userId,
        sceneId,
        Set.from(_learnedRegionIds),
      );

      // 2. 提交服务器（仅当登录时同步，失败静默忽略）
      if (_isServerSyncEnabled) {
        await _rewardService.submitProgressToServer(
          userId: _userId,
          sceneId: sceneId,
          learnedRegionIds: Set.from(_learnedRegionIds),
          starsEarned: _starsAwarded,
          isCompleted: _starsAwarded >= 3,
          studyTimeSeconds: studyTime,
        );
      }

      return true;
    } catch (e) {
      AppLogger.error('saveProgress 失败', e);
      return false;
    }
  }

  String _getSceneId() {
    if (_scene != null && _scene is Map) {
      return (_scene['id'] ?? _scene['scene_id'] ?? '').toString();
    }
    if (_jsonFilePath.isNotEmpty) {
      return _jsonFilePath.split('/').last.replaceAll('.json', '');
    }
    return '';
  }

  // ─── 调试 ─────────────────────────────────────────────────────
  String getDiagnostics() {
    return '''
Interactive Image Diagnostics:
- isLoaded: ${isLoaded.value}
- imageWidth: ${imageWidth.value}
- imageHeight: ${imageHeight.value}
- regions count: ${regions.length}
- loadingProgress: ${(loadingProgress.value * 100).toStringAsFixed(1)}%
- starsEarned: ${starsEarned.value}
- learnedCount: ${_learnedRegionIds.length}
- error: ${errorMessage.value ?? 'none'}
    ''';
  }

  /// 播放本地音效（使用独立的 SFX 通道）
  void playSfx(String assetPath) {
    _audioPlayback.playAudioFile(assetPath).catchError((e) {
      AppLogger.error('Failed to play SFX $assetPath', e);
    });
  }

  // ─── 生命周期 ─────────────────────────────────────────────────
  @override
  void onClose() {
    _strokeStartTimer?.cancel();
    _blankAreaClickTimer?.cancel();
    _audioPlayback.dispose();
    super.onClose();
  }

  // ─── 笔画动画辅助 ─────────────────────────────────────────────
  void initializeCharacterProgress(String text) {
    if (_lastInitializedText == text &&
        totalCharCount.value == _countCharacters(text)) {
      return;
    }
    _setupCharacterProgress(text);
  }

  void onCharacterAnimationComplete(int index) {
    if (index != currentCharIndex.value) return;
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
    if (_isSpeaking) await _audioPlayback.stop();
    _isSpeaking = true;
    isSpeaking.value = true;
    try {
      await action();
      if (_hasTtsPlaybackError) {
        errorMessage.value = null;
        _hasTtsPlaybackError = false;
      }
    } catch (e) {
      errorMessage.value = _buildTtsPlaybackErrorMessage(e);
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

  int _countCharacters(String text) =>
      text.split('').where((char) => char.trim().isNotEmpty).length;

  void _scheduleCharacterAnimation(String text) {
    _strokeStartTimer?.cancel();
    _strokeStartTimer = Timer(_strokeStartDelay, () {
      if (isClosed) return;
      _restartCharacterAnimation(text);
    });
  }

  void onBlankAreaClicked() {
    _blankAreaClickCount++;
    _blankAreaClickTimer?.cancel();
    _blankAreaClickTimer = Timer(_blankAreaClickTimeout, () {
      _blankAreaClickCount = 0;
    });
    if (_blankAreaClickCount >= 3) {
      _playBlankAreaHint();
      _blankAreaClickCount = 0;
      _blankAreaClickTimer?.cancel();
    }
  }

  Future<void> _playBlankAreaHint() async {
    await _interruptAndSpeak(() async {
      await _audioPlayback.playAudioFile('assets/audio/blank_area_hint.mp3');
    });
  }
}
