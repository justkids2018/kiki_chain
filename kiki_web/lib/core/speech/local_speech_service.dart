import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import '../../domain/entities/interactive_region.dart';
import '../logging/app_logger.dart';
import '../settings/app_settings_service.dart';
import 'audio_playback_service.dart';
import 'model_download_manager.dart';
import 'sherpa_tts_engine.dart';
import 'speech_service.dart';

/// 全本地语音服务
///
/// 使用 sherpa-onnx VITS 模型推理，just_audio 播放。
/// 模型首次使用时自动下载并缓存到 App Documents 目录。
class LocalSpeechService implements SpeechService {
  // Aishell3 is a multi-speaker model. Keep this as a single knob for voice style.
  static const int _zhChildLikeSid = 41;
  // en_US-amy-low is single-speaker; keep sid explicit for future model swaps.
  static const int _enDefaultSid = 0;

  late final TtsModelConfig _zhConfig;
  late final TtsModelConfig _enConfig;

  late final ModelDownloadManager _downloader;
  late final AudioPlaybackService _playback;

  SherpaOnnxTtsEngine? _zhEngine;
  SherpaOnnxTtsEngine? _enEngine;

  Directory? _tmpDir;
  bool _disposed = false;
  bool _bindingsInitialized = false;

  LocalSpeechService() {
    _zhConfig = zhAishell3Config();
    _enConfig = enLessacConfig();
    _downloader = ModelDownloadManager();
    _playback = AudioPlaybackService();
  }

  AppSettingsService? get _settings => Get.isRegistered<AppSettingsService>()
      ? Get.find<AppSettingsService>()
      : null;

  Map<String, double> get _rates =>
      _settings?.getSpeedRates() ?? {'chinese': 0.82, 'english': 0.9};

  int _speakerIdForLanguage(String language) {
    if (language.startsWith('zh')) {
      return _zhChildLikeSid;
    }
    return _enDefaultSid;
  }

  @override
  Future<void> initialize() async {
    if (_disposed) return;
    _ensureBindings();
    _tmpDir = await getTemporaryDirectory();
    // Engines are loaded lazily on first speak to avoid blocking page load
  }

  void _ensureBindings() {
    if (_bindingsInitialized) return;
    sherpa_onnx.initBindings();
    _bindingsInitialized = true;
  }

  /// 按需初始化指定语言的推理引擎（包括下载模型）
  Future<SherpaOnnxTtsEngine?> _ensureEngine(String language) async {
    if (_disposed) return null;

    final isChinese = language.startsWith('zh');
    final existing = isChinese ? _zhEngine : _enEngine;
    if (existing != null && existing.isInitialized) return existing;

    final config = isChinese ? _zhConfig : _enConfig;

    // 1. 下载模型（如已存在则跳过）
    final ready = await _downloader.isReady(config);
    if (!ready) {
      AppLogger.error(
        '[LocalSpeech] Local model not ready: ${config.dirName}. '
        'Please ensure assets/tts_models/${config.dirName}/ is bundled and '
        'reinstall the app (hot reload does not refresh bundled assets).',
      );
      return null;
    }

    // 2. 加载模型
    final modelDir = await _downloader.modelDirPath(config);
    final engine = SherpaOnnxTtsEngine(config: config, modelDir: modelDir);
    try {
      await engine.initialize();
    } catch (e) {
      AppLogger.error('[LocalSpeech] Engine init failed', e);
      return null;
    }

    if (isChinese) {
      _zhEngine = engine;
    } else {
      _enEngine = engine;
    }
    return engine;
  }

  @override
  Future<void> speakRegion(InteractiveRegion region) async {
    if (_disposed) return;
    await stop();
    final rates = _rates;
    await _speak(text: region.text, language: 'zh-CN', rate: rates['chinese']!);
    if (region.textEnglish.isNotEmpty) {
      await _speak(
          text: region.textEnglish, language: 'en-US', rate: rates['english']!);
    }
  }

  @override
  Future<void> speakPinyin(InteractiveRegion region) async {
    if (_disposed) return;
    final rates = _rates;
    await _speak(
      text: region.textPinyin,
      language: 'zh-CN',
      rate: rates['chinese']!,
    );
  }

  @override
  Future<void> speak(String text, {String language = 'zh-CN'}) async {
    if (_disposed) return;
    final isChinese = language.startsWith('zh');
    final rates = _rates;
    await _speak(
      text: text,
      language: language,
      rate: isChinese ? rates['chinese']! : rates['english']!,
    );
  }

  Future<void> _speak({
    required String text,
    required String language,
    required double rate,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _disposed) return;

    _ensureBindings();
    final engine = await _ensureEngine(language);
    if (engine == null) {
      final err = StateError(
          'TTS engine unavailable for $language. Model may be missing or failed to initialize.');
      AppLogger.warning('[LocalSpeech] $err');
      throw err;
    }

    try {
      final tmp = _tmpDir ?? await getTemporaryDirectory();
      final wavPath =
          await buildWavTempPath(tmp, language.replaceAll('-', '_'));
      final sid = _speakerIdForLanguage(language);

      // speed = 1.0 / rate 将语速系数转为 sherpa lengthScale 等效值
      // sherpa speed >1 = 更快，与 flutter_tts rate 语义相同
      await engine.generate(
        text: trimmed,
        wavPath: wavPath,
        sid: sid,
        speed: rate,
      );
      await _playback.playWav(wavPath);

      // 播放后异步清理临时文件
      File(wavPath).delete().catchError((_) => File(wavPath));
    } catch (e) {
      AppLogger.error('[LocalSpeech] speak failed: "$trimmed" [$language]', e);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    await _playback.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    _zhEngine?.dispose();
    _enEngine?.dispose();
    _playback.dispose();
    _downloader.dispose();
  }
}
