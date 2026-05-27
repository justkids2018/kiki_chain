import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

class CachedRemoteAudioService {
  final AudioPlayer _player = AudioPlayer();
  final Map<String, Future<File>> _inFlightDownloads = {};
  Directory? _cacheDir;
  bool _disposed = false;

  Future<void> initialize() async {
    if (_disposed) return;
    _cacheDir ??= await _resolveCacheDir();
  }

  Future<void> playUrl(String url) async {
    if (_disposed) return;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    await initialize();

    final cachedFile = await _getCachedFile(trimmed);
    try {
      await _player.stop();
      await _player.setFilePath(cachedFile.path);
      await _player.seek(Duration.zero);
      await _player.play();

      await _player.playerStateStream
          .firstWhere(
            (state) => state.processingState == ProcessingState.completed,
          )
          .timeout(const Duration(seconds: 30));

      await _player.stop();
      AppLogger.debug('[RemoteAudio] Finished: $trimmed');
    } catch (e) {
      AppLogger.error('[RemoteAudio] Error playing $trimmed', e);
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
