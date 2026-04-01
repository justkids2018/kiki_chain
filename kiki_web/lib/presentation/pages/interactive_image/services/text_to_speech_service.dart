import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_service.dart';
import '../../../../domain/entities/interactive_region.dart';
import 'cloud_tts_service.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  final CloudTtsService _cloudTts = CloudTtsService();
  AppSettingsService? _settings;
  bool _disposed = false;
  bool _initialized = false;

  TextToSpeechService();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Android：必须先设置音量，否则部分机型静音
      if (!kIsWeb && Platform.isAndroid) {
        await _initAndroid();
      } else if (!kIsWeb && Platform.isIOS) {
        await _initIos();
      }

      await _tts.awaitSpeakCompletion(true);
      await _tts.setPitch(1.3);
      await _tts.setVolume(1.0);

      // 注册错误回调，方便排查 Android 问题
      _tts.setErrorHandler((msg) {
        AppLogger.error('TTS error: $msg');
      });

      _initialized = true;
      AppLogger.info('TTS initialized');
    } catch (e) {
      AppLogger.error('TTS initialization failed', e);
    }
  }

  Future<void> _initAndroid() async {
    try {
      // 优先使用 Google TTS 引擎（发音最好）
      await _tts.setEngine('com.google.android.tts');
    } catch (_) {
      // 没有 Google TTS 时使用系统默认引擎，忽略错误
    }
    // setSharedInstance 是 iOS 专属 API，Android 上跳过
  }

  Future<void> _initIos() async {
    try {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    } catch (_) {}
  }

  Future<void> speakRegion(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      await stop();
      final rates = _getRates();

      await _speak(text: region.text, lang: 'zh-CN', rate: rates['chinese']!);

      if (region.textEnglish.isNotEmpty) {
        await _speak(text: region.textEnglish, lang: 'en-US', rate: rates['english']!);
      }
    } catch (e) {
      AppLogger.error('TTS speakRegion error', e);
    }
  }

  Future<void> speakPinyin(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      final rates = _getRates();
      await _speak(text: region.textPinyin, lang: 'zh-CN', rate: rates['chinese']!);
    } catch (e) {
      AppLogger.error('TTS speakPinyin error', e);
    }
  }

  Future<void> speak(String text, {String language = 'en-US'}) async {
    if (_disposed) return;
    try {
      final rates = _getRates();
      final isChinese = language == 'zh-CN' || language == 'zh';
      await _speak(
        text: text,
        lang: isChinese ? 'zh-CN' : 'en-US',
        rate: isChinese ? rates['chinese']! : rates['english']!,
      );
    } catch (e) {
      AppLogger.error('TTS speak error', e);
    }
  }

  Map<String, double> _getRates() {
    _settings ??= Get.isRegistered<AppSettingsService>()
        ? Get.find<AppSettingsService>()
        : null;
    return _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};
  }

  Future<void> _speak({
    required String text,
    required String lang,
    required double rate,
  }) async {
    if (text.trim().isEmpty || _disposed) return;
    try {
      // 1. 尝试云 TTS（Edge TTS → Azure TTS）
      final cloudSuccess = await _cloudTts.speak(text, language: lang);
      if (cloudSuccess) {
        AppLogger.info('Cloud TTS success: "$text"');
        return;
      }

      // 2. 降级到系统 TTS
      AppLogger.info('Fallback to system TTS: "$text"');
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.3);
      final result = await _tts.speak(text);
      AppLogger.info('System TTS result: $result — "$text"');
    } catch (e) {
      AppLogger.error('TTS _speak failed', e);
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      AppLogger.warning('TTS stop error', e);
    }
  }

  void dispose() {
    _disposed = true;
    _tts.stop();
    _cloudTts.dispose();
  }
}
