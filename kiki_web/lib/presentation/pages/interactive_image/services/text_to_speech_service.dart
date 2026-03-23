import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_service.dart';
import '../../../../domain/entities/interactive_region.dart';

/// 系统 TTS 语音合成服务（支持儿童声音）
///
/// 使用系统内置的 TTS 引擎，完全免费，无需注册
/// iOS 和 Android 都支持儿童声音选择
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  AppSettingsService? _settings;
  bool _disposed = false;

  TextToSpeechService();

  /// Initialize TTS with child-friendly voices
  Future<void> initialize() async {
    try {
      await _tts.setSharedInstance(true);

      // iOS 音频配置
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

      // 设置音调（提高音调使声音更像儿童）
      await _tts.setPitch(1.3); // 1.0 是正常，1.3 更高更像儿童

      AppLogger.info('✅ TTS initialized with child-friendly voice');
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
      await _speak(
        text: region.text,
        lang: 'zh-CN',
        rate: rates['chinese']!,
      );

      // 说英文
      if (region.textEnglish.isNotEmpty) {
        await _speak(
          text: region.textEnglish,
          lang: 'en-US',
          rate: rates['english']!,
        );
      }
    } catch (e) {
      AppLogger.error('🎤 TTS error', e);
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

      await _speak(
        text: region.textPinyin,
        lang: 'zh-CN',
        rate: rates['chinese']!,
      );
    } catch (e) {
      AppLogger.error('🎤 TTS error', e);
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
        text: text,
        lang: isChinese ? 'zh-CN' : 'en-US',
        rate: isChinese ? rates['chinese']! : rates['english']!,
      );
    } catch (e) {
      AppLogger.error('🎤 TTS error', e);
    }
  }

  /// 系统 TTS 播放（使用儿童音调）
  Future<void> _speak({
    required String text,
    required String lang,
    required double rate,
  }) async {
    if (text.trim().isEmpty || _disposed) return;

    try {
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(1.3); // 儿童音调
      await _tts.speak(text);
      AppLogger.info('🔊 Speaking: ${text.substring(0, text.length > 20 ? 20 : text.length)}...');
    } catch (e) {
      AppLogger.error('❌ TTS playback failed', e);
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
