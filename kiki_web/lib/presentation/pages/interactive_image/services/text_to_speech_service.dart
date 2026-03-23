import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_service.dart';
import '../../../../domain/entities/interactive_region.dart';

/// 使用系统 TTS 的语音合成服务
///
/// 使用 flutter_tts 提供跨平台的语音合成功能
/// 支持中文和英文语音播放
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  AppSettingsService? _settings;
  bool _disposed = false;

  TextToSpeechService();

  /// Initialize TTS
  Future<void> initialize() async {
    try {
      await _tts.setSharedInstance(true);
      try {
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
      await _tts.awaitSpeakCompletion(true);
      AppLogger.info('✅ TTS initialized successfully (System TTS)');
    } catch (e) {
      AppLogger.error('❌ TTS initialization failed', e);
    }
  }

  /// Speak the region's audio (Chinese and English)
  Future<void> speakRegion(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      await stop();

      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      // 说中文
      await _speak(region.text, 'zh-CN', rates['chinese']!);

      // 说英文
      if (region.textEnglish.isNotEmpty) {
        await _speak(region.textEnglish, 'en-US', rates['english']!);
      }
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      await _speak(region.textPinyin, 'zh-CN', rates['chinese']!);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak custom text
  Future<void> speak(String text, {String language = "en-US"}) async {
    if (_disposed) return;
    try {
      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      final isChinese = language == "zh-CN" || language == "zh";
      await _speak(
        text,
        isChinese ? 'zh-CN' : 'en-US',
        isChinese ? rates['chinese']! : rates['english']!,
      );
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Internal speak method
  Future<void> _speak(String text, String lang, double rate) async {
    if (text.trim().isEmpty || _disposed) return;

    try {
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(rate);
      await _tts.speak(text);
    } catch (e) {
      AppLogger.error('TTS speak failed', e);
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      AppLogger.warning('TTS stop error', e);
    }
  }

  /// Dispose TTS resources
  void dispose() {
    _disposed = true;
    _tts.stop();
  }
}
