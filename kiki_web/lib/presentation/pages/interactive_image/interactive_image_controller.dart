import 'package:get/get.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/interactive_region.dart';
import '../../../data/repositories/interactive_image/i_interactive_image_repository.dart';
import '../../../data/repositories/interactive_image/interactive_image_repository_impl.dart';
import 'services/text_to_speech_service.dart';

class InteractiveImageController extends GetxController {
  late final IInteractiveImageRepository _repository;
  late final TextToSpeechService _ttsService;

  final regions = <InteractiveRegion>[].obs;
  final imageWidth = 1.0.obs;
  final imageHeight = 1.0.obs;
  final isLoaded = false.obs;
  final errorMessage = RxnString();
  final loadingProgress = 0.0.obs;

  // UI State
  final isAutoPlay = false.obs;
  final activeRegion = Rxn<InteractiveRegion>();

  // 动态数据：从导航参数接收
  late String _jsonFilePath;
  late String _imagePath;

  InteractiveImageController({
    IInteractiveImageRepository? repository,
    TextToSpeechService? ttsService,
  }) {
    _repository = repository ?? InteractiveImageRepositoryImpl();
    _ttsService = ttsService ?? TextToSpeechService();

    // 从导航参数获取文件路径和图片路径
    _getParametersFromRoute();
  }

  /// 从路由参数获取 JSON 文件和图片路径
  void _getParametersFromRoute() {
    // 获取传递的参数
    final arguments = Get.arguments;

    if (arguments != null && arguments is Map) {
      _jsonFilePath =
          arguments['jsonFile'] ?? 'assets/data/kiki_zhiwuyuan.json';
      // 根据 JSON 文件名推断图片路径
      _imagePath = _getImagePathFromJsonFile(_jsonFilePath);
    } else {
      // 默认值
      _jsonFilePath = 'assets/data/kiki_zhiwuyuan.json';
      _imagePath = 'assets/images/kiki_zhiwuyuan.jpg';
    }

    AppLogger.debug('JSON File = $_jsonFilePath');
    AppLogger.debug('Image Path = $_imagePath');
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
    if (jsonFile.contains('dongwuyuan')) {
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

      // Initialize TTS - continue even if it fails
      try {
        AppLogger.debug('Initializing TTS');
        await _ttsService.initialize();
        AppLogger.debug('TTS initialized successfully');
      } catch (e) {
        AppLogger.warning('TTS initialization failed', e);
        // Continue without TTS
      }
      loadingProgress.value = 0.3;

      // Load regions and image dimensions in parallel
      AppLogger.debug('Starting data loading');
      await Future.wait([
        _loadRegions(),
        _loadImageDimensions(),
      ]);

      AppLogger.debug('Data loading completed');
      loadingProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 300));
      isLoaded.value = true;
    } catch (e) {
      AppLogger.error('Initialization error', e);
      errorMessage.value = "Failed to initialize: $e";
      isLoaded.value = true; // Set to loaded to show error UI
    }
  }

  Future<void> _loadRegions() async {
    try {
      AppLogger.debug('Loading regions from: $_jsonFilePath');
      final loadedRegions =
          await _repository.loadRegions(jsonPath: _jsonFilePath);
      if (loadedRegions.isNotEmpty) {
        regions.assignAll(loadedRegions);
        AppLogger.info('Loaded ${loadedRegions.length} regions');
      } else {
        AppLogger.warning('No regions loaded from: $_jsonFilePath');
      }
      loadingProgress.value = 0.7;
    } catch (e) {
      AppLogger.error('Error loading regions', e);
      errorMessage.value = "Failed to load regions: $e";
    }
  }

  Future<void> _loadImageDimensions() async {
    try {
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

  /// Speak a region's audio (Chinese and English)
  Future<void> speakRegion(InteractiveRegion region) async {
    activeRegion.value = region;
    await _ttsService.speakRegion(region);
  }

  /// Speak only the pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    await _ttsService.speakPinyin(region);
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
    _ttsService.dispose();
    super.onClose();
  }
}
