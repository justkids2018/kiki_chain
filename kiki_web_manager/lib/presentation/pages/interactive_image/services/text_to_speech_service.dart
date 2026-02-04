import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../domain/entities/interactive_region.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  TextToSpeechService();

  /// Initialize TTS engine
  Future<void> initialize() async {
    try {
      AppLogger.debug('Initializing TTS');
      await _tts.setSharedInstance(true);
      
      // Only set iOS specific settings if platform is iOS
      try {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
        AppLogger.debug('iOS audio category configured');
      } catch (e) {
        AppLogger.warning('iOS audio category setup failed', e);
      }
      
      await _tts.awaitSpeakCompletion(true);
      
      // 设置全局 TTS 参数优化中文
      await _tts.setSpeechRate(0.85); // 稍微减慢速度，让中文更清晰
      await _tts.setVolume(1.0); // 最大音量
      await _tts.setPitch(1.0); // 正常音调
      
      AppLogger.debug('TTS initialization completed');
    } catch (e) {
      AppLogger.error('TTS initialization error', e);
      // Don't re-throw, allow app to continue without TTS
    }
  }

  /// Speak the region's Chinese text and English text
  Future<void> speakRegion(InteractiveRegion region) async {
    try {
      // Speak Chinese with optimized settings
      await _setChineseSettings();
      await _tts.speak(region.text);

      // Speak English with optimized settings
      await _setEnglishSettings();
      await _tts.speak(region.textEnglish);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    try {
      await _setChineseSettings();
      await _tts.speak(region.textPinyin);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak custom text
  Future<void> speak(String text, {String language = "en-US"}) async {
    try {
      if (language == "zh-CN" || language == "zh") {
        await _setChineseSettings();
      } else {
        await _setEnglishSettings();
      }
      await _tts.speak(text);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// 设置中文语音参数（优化中文发音）
  Future<void> _setChineseSettings() async {
    try {
      await _tts.setLanguage("zh-CN");
      await _tts.setSpeechRate(0.85); // 中文稍慢，更清晰
      await _tts.setVolume(1.0); // 最大音量
      await _tts.setPitch(1.0); // 正常音调
    } catch (e) {
      AppLogger.warning('Failed to set Chinese TTS settings', e);
    }
  }

  /// 设置英文语音参数
  Future<void> _setEnglishSettings() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(1.0); // 英文正常速度
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      AppLogger.warning('Failed to set English TTS settings', e);
    }
  }

  /// Dispose TTS resources
  void dispose() {
    _tts.stop();
  }
}
