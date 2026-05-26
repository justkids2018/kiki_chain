import '../../domain/entities/interactive_region.dart';
import 'cached_remote_audio_service.dart';
import 'local_speech_service.dart';
import 'speech_service.dart';

class AudioPlaybackComponent {
  final SpeechService _ttsService;
  final CachedRemoteAudioService _remoteAudioService;

  AudioPlaybackComponent({
    SpeechService? ttsService,
    CachedRemoteAudioService? remoteAudioService,
  })  : _ttsService = ttsService ?? LocalSpeechService(),
        _remoteAudioService = remoteAudioService ?? CachedRemoteAudioService();

  Future<void> initialize() async {
    await _remoteAudioService.initialize();
    await _ttsService.initialize();
  }

  Future<void> playRegion(InteractiveRegion region) async {
    final mode = region.normalizedAudioSourceType;
    if (mode == 'tts') {
      await _ttsService.speakRegion(region);
      return;
    }

    final hasCn = region.audioCnUrl.trim().isNotEmpty;
    final hasEn = region.audioEnUrl.trim().isNotEmpty;
    if (!hasCn && !hasEn) {
      await _ttsService.speakRegion(region);
      return;
    }

    if (hasCn) {
      await _remoteAudioService.playUrl(region.audioCnUrl);
    }
    if (hasEn) {
      await _remoteAudioService.playUrl(region.audioEnUrl);
    }
  }

  Future<void> playPinyin(InteractiveRegion region) async {
    await _ttsService.speakPinyin(region);
  }

  Future<void> playEnglishWord(InteractiveRegion region) async {
    final mode = region.normalizedAudioSourceType;
    final url = region.audioEnUrl.trim();
    if (mode != 'tts' && url.isNotEmpty) {
      await _remoteAudioService.playUrl(url);
      return;
    }

    final english = region.textEnglish.trim();
    if (english.isNotEmpty) {
      await _ttsService.speak(english, language: 'en-US');
    }
  }

  Future<void> playChinesePhrase(InteractiveRegion region) async {
    final mode = region.normalizedAudioSourceType;
    final url = region.audioCnUrl.trim();
    if (mode != 'tts' && url.isNotEmpty) {
      await _remoteAudioService.playUrl(url);
      return;
    }

    final chinese = region.text.trim();
    if (chinese.isNotEmpty) {
      await _ttsService.speak(chinese, language: 'zh-CN');
    }
  }

  Future<void> playChineseChar(String character) async {
    final trimmed = character.trim();
    if (trimmed.isEmpty) return;
    await _ttsService.speak(trimmed, language: 'zh-CN');
  }

  Future<void> stop() async {
    await _remoteAudioService.stop();
    await _ttsService.stop();
  }

  void dispose() {
    _remoteAudioService.dispose();
    _ttsService.dispose();
  }
}
