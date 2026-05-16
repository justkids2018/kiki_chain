import 'dart:async';
import 'package:get/get.dart';
import '../../../core/logging/app_logger.dart';
import '../../../data/models/image_item.dart';
import '../../../domain/entities/interactive_region.dart';
import '../../../data/repositories/interactive_image/i_interactive_image_repository.dart';
import '../../../data/repositories/interactive_image/interactive_image_repository_impl.dart';
import '../../../core/speech/local_speech_service.dart';
import '../../../core/speech/speech_service.dart';

class InteractiveImageController extends GetxController {
  late final IInteractiveImageRepository _repository;
  late final SpeechService _ttsService;

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
  String? _lastInitializedText;
  bool _singleCharacterMode = false;

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
    SpeechService? ttsService,
  }) {
    _repository = repository ?? InteractiveImageRepositoryImpl();
    _ttsService = ttsService ?? LocalSpeechService();

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
          _imagePath =
              _scene['interactive_image'] ?? _scene['interactiveImage'] ?? '';
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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      AppLogger.debug('Initialization started');
      errorMessage.value = null;
      loadingProgress.value = 0.1;

      // 优先预热中文 TTS，减少首次点击中文时的卡顿。
      // 超时后继续加载数据，TTS 会在后台继续初始化（首次播放可能略有延迟）
      loadingProgress.value = 0.25;
      try {
        await _ttsService.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.warning(
                '⏱️ TTS warmup timed out after 5s, will continue in background');
            // TTS 会在首次播放时自动完成初始化
          },
        );
      } catch (e) {
        AppLogger.error('❌ TTS warmup failed, continue with data loading', e);
      }

      // 只等待数据加载（最多 15 秒）
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

  /// Speak a region's audio (Chinese and English)
  Future<void> speakRegion(InteractiveRegion region) async {
    AppLogger.info(
        '🔊 Speaking region: ${region.text} / ${region.textEnglish}');

    // Update UI immediately for instant visual feedback
    activeRegion.value = region;
    _scheduleCharacterAnimation(region.text);

    await _interruptAndSpeak(() async {
      await _ttsService.speakRegion(region);
    });
  }

  /// Speak only the pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _ttsService.speakPinyin(region);
    });
  }

  /// Speak only English word for the active region.
  Future<void> speakEnglishWord(InteractiveRegion region) async {
    final english = region.textEnglish.trim();
    if (english.isEmpty) return;

    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _ttsService.speak(english, language: 'en-US');
    });
  }

  /// Speak Chinese phrase only (used by the "点击朗读" button).
  /// Note: Does not restart character animation to avoid interrupting user's current progress.
  Future<void> speakChinesePhrase(InteractiveRegion region) async {
    final chinese = region.text.trim();
    if (chinese.isEmpty) return;

    activeRegion.value = region;
    await _interruptAndSpeak(() async {
      await _ttsService.speak(chinese, language: 'zh-CN');
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

    activeRegion.value = region;
    _focusCharacter(region.text, charIndex);
    await _interruptAndSpeak(() async {
      await _ttsService.speak(trimmed, language: 'zh-CN');
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
    _ttsService.dispose();
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
      await _ttsService.stop();
    }
    _isSpeaking = true;
    isSpeaking.value = true;
    try {
      await action();
      if (errorMessage.value?.startsWith('语音播放失败') == true) {
        errorMessage.value = null;
      }
    } catch (e) {
      final message = '语音播放失败，请检查模型文件与音频输出设备。\n$e';
      errorMessage.value = message;
      AppLogger.error('TTS action failed', e);
    } finally {
      _isSpeaking = false;
      isSpeaking.value = false;
    }
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
}
