import '../../domain/entities/interactive_region.dart';
import 'cached_remote_audio_service.dart';

class AudioPlaybackComponent {
  final CachedRemoteAudioService _remoteAudioService;

  AudioPlaybackComponent({
    CachedRemoteAudioService? remoteAudioService,
  }) : _remoteAudioService = remoteAudioService ?? CachedRemoteAudioService();

  Future<void> initialize() async {
    await _remoteAudioService.initialize();
  }

  Future<void> playRegion(InteractiveRegion region) async {
    final hasCn = region.audioCnUrl.trim().isNotEmpty;
    final hasEn = region.audioEnUrl.trim().isNotEmpty;
    if (!hasCn && !hasEn) return;

    if (hasCn) {
      await _remoteAudioService.playUrl(region.audioCnUrl);
    }
    if (hasEn) {
      await _remoteAudioService.playUrl(region.audioEnUrl);
    }
  }

  Future<void> playPinyin(InteractiveRegion region) async {
    final hasEn = region.audioEnUrl.trim().isNotEmpty;
    if (hasEn) {
      await _remoteAudioService.playUrl(region.audioEnUrl);
    }
  }

  Future<void> playEnglishWord(InteractiveRegion region) async {
    final url = region.audioEnUrl.trim();
    if (url.isNotEmpty) {
      await _remoteAudioService.playUrl(url);
    }
  }

  Future<void> playChinesePhrase(InteractiveRegion region) async {
    final url = region.audioCnUrl.trim();
    if (url.isNotEmpty) {
      await _remoteAudioService.playUrl(url);
    }
  }

  Future<void> playChineseChar(String character) async {
    // TTS removed: character-level playback is disabled when no per-char audio URL exists.
  }

  Future<void> stop() async {
    await _remoteAudioService.stop();
  }

  void dispose() {
    _remoteAudioService.dispose();
  }
}
