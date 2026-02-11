import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tts_provider.dart';

/// Kiki TTS 服务
///
/// 简单、清晰的 TTS 服务封装
/// - 依赖注入 TTS 提供商
/// - 可选的音频缓存
/// - 统一的播放控制
class KikiTTSService {
  /// TTS 提供商（外部注入）
  final TTSProvider provider;

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 缓存目录
  Directory? _cacheDir;

  /// 是否启用缓存
  final bool enableCache;

  /// 缓存过期天数
  final int cacheExpirationDays;

  KikiTTSService({
    required this.provider,
    this.enableCache = true,
    this.cacheExpirationDays = 30,
  });

  /// 初始化服务
  Future<void> initialize() async {
    // 初始化提供商
    await provider.initialize();

    // 初始化缓存
    if (enableCache) {
      await _initializeCache();
    }

    print('✅ Kiki TTS 服务初始化完成 (${provider.providerName})');
  }

  /// 说话（主方法）
  Future<void> speak(
    String text, {
    String language = 'zh-CN',
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  }) async {
    if (text.isEmpty) return;

    try {
      // 1. 检查缓存
      if (enableCache) {
        final cachedAudio = await _getCachedAudio(text, language);
        if (cachedAudio != null) {
          await _playAudioFile(cachedAudio);
          return;
        }
      }

      // 2. 生成音频
      final audioBytes = await provider.synthesize(
        text: text,
        language: language,
        speed: speed,
        pitch: pitch,
        emotion: emotion,
      );

      // 3. 缓存音频
      if (enableCache) {
        await _cacheAudio(text, language, audioBytes);
      }

      // 4. 播放音频
      await _playAudioBytes(audioBytes);
    } catch (e) {
      print('❌ TTS 播放失败: $e');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// 暂停播放
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// 继续播放
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// 初始化缓存
  Future<void> _initializeCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/tts_cache');

      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      await _cleanExpiredCache();
    } catch (e) {
      print('⚠️ TTS 缓存初始化失败: $e');
    }
  }

  /// 获取缓存的音频
  Future<File?> _getCachedAudio(String text, String language) async {
    if (_cacheDir == null) return null;

    final hash = _generateHash(text, language);
    final file = File('${_cacheDir!.path}/$hash.mp3');

    if (await file.exists()) {
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified).inDays;

      if (age < cacheExpirationDays) {
        return file;
      } else {
        await file.delete();
      }
    }

    return null;
  }

  /// 缓存音频
  Future<void> _cacheAudio(
    String text,
    String language,
    List<int> audioBytes,
  ) async {
    if (_cacheDir == null) return;

    try {
      final hash = _generateHash(text, language);
      final file = File('${_cacheDir!.path}/$hash.mp3');
      await file.writeAsBytes(audioBytes);
    } catch (e) {
      print('⚠️ 音频缓存失败: $e');
    }
  }

  /// 播放音频文件
  Future<void> _playAudioFile(File file) async {
    await _audioPlayer.play(DeviceFileSource(file.path));
  }

  /// 播放音频字节
  Future<void> _playAudioBytes(List<int> bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await tempFile.writeAsBytes(bytes);

    await _audioPlayer.play(DeviceFileSource(tempFile.path));

    // 播放完成后删除临时文件
    _audioPlayer.onPlayerComplete.listen((_) async {
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        // 忽略删除错误
      }
    });
  }

  /// 生成文本哈希
  String _generateHash(String text, String language) {
    final content = '$text-$language-${provider.providerName}';
    final bytes = utf8.encode(content);
    return md5.convert(bytes).toString();
  }

  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    if (_cacheDir == null) return;

    try {
      final files = await _cacheDir!.list().toList();
      int deletedCount = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = DateTime.now().difference(stat.modified).inDays;

          if (age >= cacheExpirationDays) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        print('🗑️ 已清理 $deletedCount 个过期缓存');
      }
    } catch (e) {
      print('⚠️ 清理缓存失败: $e');
    }
  }

  /// 获取缓存统计
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_cacheDir == null) {
      return {'enabled': false};
    }

    try {
      final files = await _cacheDir!.list().toList();
      int totalSize = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return {
        'enabled': true,
        'fileCount': files.length,
        'totalSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {'enabled': true, 'error': e.toString()};
    }
  }

  /// 清空缓存
  Future<void> clearCache() async {
    if (_cacheDir == null) return;

    try {
      final files = await _cacheDir!.list().toList();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      print('🗑️ 已清空 TTS 缓存');
    } catch (e) {
      print('❌ 清空缓存失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
    await provider.dispose();
  }
}
