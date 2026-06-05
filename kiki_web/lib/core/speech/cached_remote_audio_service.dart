import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

class CachedRemoteAudioService {
  AudioPlayer? _player;
  final Map<String, Future<File>> _inFlightDownloads = {};
  Directory? _cacheDir;
  bool _disposed = false;
  String? _currentPlayingUrl;

  Future<void> initialize() async {
    if (_disposed) return;
    _cacheDir ??= await _resolveCacheDir();
    // Initialize player once
    _player ??= AudioPlayer();
  }

  Future<void> playUrl(String url) async {
    if (_disposed) return;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    // If already playing the same URL, ignore
    if (_currentPlayingUrl == trimmed) {
      AppLogger.debug('[RemoteAudio] Same audio already playing, ignoring');
      return;
    }

    await initialize();

    // If playing different audio, stop it first
    if (_currentPlayingUrl != null) {
      AppLogger.debug('[RemoteAudio] Stopping current playback');
      try {
        await _player!.stop();
      } catch (e) {
        AppLogger.debug('[RemoteAudio] Error stopping: $e');
      }
    }

    _currentPlayingUrl = trimmed;
    final cachedFile = await _getCachedFile(trimmed);

    try {
      await _player!.setFilePath(cachedFile.path);
      await _player!.play();

      // Wait for completion
      await _player!.playerStateStream
          .firstWhere(
            (state) =>
              state.processingState == ProcessingState.completed ||
              state.processingState == ProcessingState.idle,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.warning('[RemoteAudio] Playback timeout');
              return PlayerState(false, ProcessingState.idle);
            },
          );

      AppLogger.debug('[RemoteAudio] Finished: $trimmed');
    } catch (e) {
      AppLogger.error('[RemoteAudio] Error playing $trimmed', e);
    } finally {
      _currentPlayingUrl = null;
    }
  }

  /// 播放本地asset音频文件
  Future<void> playAsset(String assetPath) async {
    if (_disposed) return;
    final trimmed = assetPath.trim();
    if (trimmed.isEmpty) return;

    await initialize();

    // Stop current playback if any
    if (_currentPlayingUrl != null) {
      AppLogger.debug('[RemoteAudio] Stopping current playback');
      try {
        await _player!.stop();
      } catch (e) {
        AppLogger.debug('[RemoteAudio] Error stopping: $e');
      }
    }

    _currentPlayingUrl = trimmed;

    try {
      await _player!.setAsset(trimmed);
      await _player!.play();

      // Wait for completion
      await _player!.playerStateStream
          .firstWhere(
            (state) =>
              state.processingState == ProcessingState.completed ||
              state.processingState == ProcessingState.idle,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.warning('[RemoteAudio] Asset playback timeout');
              return PlayerState(false, ProcessingState.idle);
            },
          );

      AppLogger.debug('[RemoteAudio] Finished playing asset: $trimmed');
    } catch (e) {
      AppLogger.error('[RemoteAudio] Error playing asset $trimmed', e);
    } finally {
      _currentPlayingUrl = null;
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    try {
      await _player?.stop();
      _currentPlayingUrl = null;
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _currentPlayingUrl = null;
    _player?.dispose();
    _player = null;
  }

  Future<File> _getCachedFile(String url) async {
    final cacheDir = _cacheDir ?? await _resolveCacheDir();
    final cacheKey = sha256.convert(utf8.encode(url)).toString();
    final fileName = '$cacheKey.mp3';
    final file = File('${cacheDir.path}/$fileName');

    if (await file.exists()) {
      AppLogger.info('[RemoteAudio] Cache hit: $url');
      return file;
    }

    final inFlight = _inFlightDownloads[url];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _downloadToFile(url, file);
    _inFlightDownloads[url] = future;
    try {
      return await future;
    } finally {
      _inFlightDownloads.remove(url);
    }
  }

  Future<File> _downloadToFile(String url, File file) async {
    AppLogger.info('[RemoteAudio] Cache miss, downloading: $url');
    await file.parent.create(recursive: true);

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
      }

      await response.pipe(file.openWrite());
    } finally {
      client.close(force: true);
    }

    return file;
  }

  Future<Directory> _resolveCacheDir() async {
    final baseDir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${baseDir.path}/audio_url_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }
}
