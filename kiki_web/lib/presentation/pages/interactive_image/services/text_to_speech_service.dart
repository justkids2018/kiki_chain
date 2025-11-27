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
      AppLogger.debug('TTS initialization completed');
    } catch (e) {
      AppLogger.error('TTS initialization error', e);
      // Don't re-throw, allow app to continue without TTS
    }
  }

  /// Speak the region's Chinese text and English text
  Future<void> speakRegion(InteractiveRegion region) async {
    try {
      // Speak Chinese
      await _tts.setLanguage("zh-CN");
      await _tts.speak(region.text);

      // Speak English
      await _tts.setLanguage("en-US");
      await _tts.speak(region.textEnglish);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    try {
      await _tts.setLanguage("zh-CN");
      await _tts.speak(region.textPinyin);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak custom text
  Future<void> speak(String text, {String language = "en-US"}) async {
    try {
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Dispose TTS resources
  void dispose() {
    _tts.stop();
  }
}
