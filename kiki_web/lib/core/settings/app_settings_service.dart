import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Enum for playback speed options.
enum PlaybackSpeed {
  slow,
  normal,
  fast,
}

/// Global app settings service using GetX and GetStorage.
///
/// Manages persistent settings like playback speed for TTS.
class AppSettingsService extends GetxService {
  final _storage = GetStorage();
  static const _speedKey = 'playback_speed';

  // Observable playback speed
  final playbackSpeed = PlaybackSpeed.normal.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load settings from persistent storage.
  void _loadSettings() {
    final savedSpeed = _storage.read(_speedKey);
    if (savedSpeed != null) {
      try {
        playbackSpeed.value = PlaybackSpeed.values.firstWhere(
          (e) => e.toString() == savedSpeed,
          orElse: () => PlaybackSpeed.normal,
        );
      } catch (e) {
        playbackSpeed.value = PlaybackSpeed.normal;
      }
    }
  }

  /// Set playback speed and persist to storage.
  Future<void> setPlaybackSpeed(PlaybackSpeed speed) async {
    playbackSpeed.value = speed;
    await _storage.write(_speedKey, speed.toString());
  }

  /// Get speed rates for TTS based on current setting.
  ///
  /// Returns a map with 'chinese' and 'english' speed rates.
  Map<String, double> getSpeedRates() {
    switch (playbackSpeed.value) {
      case PlaybackSpeed.slow:
        return {'chinese': 0.5, 'english': 0.6};
      case PlaybackSpeed.normal:
        return {'chinese': 0.6, 'english': 0.7};
      case PlaybackSpeed.fast:
        return {'chinese': 0.8, 'english': 0.9};
    }
  }

  /// Get display name for playback speed.
  String getSpeedDisplayName(PlaybackSpeed speed) {
    switch (speed) {
      case PlaybackSpeed.slow:
        return '慢速';
      case PlaybackSpeed.normal:
        return '正常';
      case PlaybackSpeed.fast:
        return '快速';
    }
  }
}
