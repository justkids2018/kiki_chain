import 'package:just_audio/just_audio.dart';
import '../../domain/entities/interactive_region.dart';
import 'cached_remote_audio_service.dart';
import '../logging/app_logger.dart';

class AudioPlaybackComponent {
  final CachedRemoteAudioService _remoteAudioService;
  AudioPlayer? _sfxPlayer;

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

  /// 播放本地音频文件（使用独立的 SFX 通道，不与单词发音冲突，不泄露资源）
  Future<void> playAudioFile(String assetPath) async {
    _sfxPlayer ??= AudioPlayer();
    try {
      await _sfxPlayer!.stop();
      await _sfxPlayer!.setAsset(assetPath);
      await _sfxPlayer!.play();
    } catch (e) {
      AppLogger.error('Failed to play SFX: $assetPath', e);
    }
  }

  Future<void> stop() async {
    await _remoteAudioService.stop();
    await _sfxPlayer?.stop();
  }

  void dispose() {
    _remoteAudioService.dispose();
    _sfxPlayer?.dispose();
    _sfxPlayer = null;
  }
}
