import 'package:just_audio/just_audio.dart';
import '../logging/app_logger.dart';

/// 负责将 WAV 文件通过 just_audio 播放
class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();
  bool _disposed = false;

  /// 播放指定路径的 WAV 文件，等待播放完成
  Future<void> playWav(String wavPath) async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _player.setFilePath(wavPath);
      await _player.seek(Duration.zero);
      await _player.play();

      await _player.playerStateStream
          .firstWhere(
            (s) => s.processingState == ProcessingState.completed,
          )
          .timeout(const Duration(seconds: 30));

      await _player.stop();
      AppLogger.debug('[AudioPlayback] Finished: $wavPath');
    } catch (e) {
      AppLogger.error('[AudioPlayback] Error playing $wavPath', e);
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _player.dispose();
  }
}
