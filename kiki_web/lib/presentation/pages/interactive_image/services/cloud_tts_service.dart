import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/logging/app_logger.dart';

/// 云 TTS 服务 - 支持 Edge TTS 和 Azure TTS
class CloudTtsService {
  static const String edgeTtsBaseUrl = 'https://speech.platform.bing.com';
  static const int edgeTtsTimeout = 3000; // 3 秒
  static const int azureTtsTimeout = 5000; // 5 秒
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int cacheExpireHours = 24;

  final AudioPlayer _player = AudioPlayer();
  String? _azureApiKey;
  String? _azureRegion;
  Directory? _cacheDir;

  CloudTtsService({String? azureApiKey, String? azureRegion}) {
    _azureApiKey = azureApiKey;
    _azureRegion = azureRegion;
    _initCache();
  }

  Future<void> _initCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/tts_cache');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
      await _cleanExpiredCache();
    } catch (e) {
      AppLogger.error('Failed to init TTS cache', e);
    }
  }

  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    if (_cacheDir == null) return;
    try {
      final now = DateTime.now();
      final files = await _cacheDir!.list().toList();
      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          if (age.inHours > cacheExpireHours) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to clean TTS cache', e);
    }
  }

  /// 生成缓存 key
  String _getCacheKey(String text, String voice, String language) {
    final content = '$text|$voice|$language';
    return md5.convert(utf8.encode(content)).toString();
  }

  /// 获取缓存文件路径
  String? _getCachePath(String cacheKey) {
    if (_cacheDir == null) return null;
    return '${_cacheDir!.path}/$cacheKey.mp3';
  }

  /// 从缓存读取音频
  Future<String?> _readFromCache(String cacheKey) async {
    final path = _getCachePath(cacheKey);
    if (path == null) return null;
    try {
      final file = File(path);
      if (await file.exists()) {
        AppLogger.debug('TTS cache hit: $cacheKey');
        return path;
      }
    } catch (e) {
      AppLogger.warning('Failed to read TTS cache', e);
    }
    return null;
  }

  /// 写入缓存
  Future<void> _writeToCache(String cacheKey, List<int> audioData) async {
    final path = _getCachePath(cacheKey);
    if (path == null) return;
    try {
      final file = File(path);
      await file.writeAsBytes(audioData);
      AppLogger.debug('TTS cached: $cacheKey');
    } catch (e) {
      AppLogger.warning('Failed to write TTS cache', e);
    }
  }

  /// 播放音频文件
  Future<void> _playAudio(String audioPath) async {
    try {
      await _player.setFilePath(audioPath);
      await _player.play();
      await _player.stop();
    } catch (e) {
      AppLogger.error('Failed to play audio', e);
      rethrow;
    }
  }

  /// Edge TTS 语音合成
  Future<String?> _edgeTtsSpeak(
    String text,
    String voice,
    String language,
  ) async {
    try {
      final cacheKey = _getCacheKey(text, voice, language);

      // 检查缓存
      final cachedPath = await _readFromCache(cacheKey);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 调用 Edge TTS API
      final response = await http
          .post(
            Uri.parse('$edgeTtsBaseUrl/synthesize'),
            headers: {
              'Content-Type': 'application/ssml+xml',
              'X-Microsoft-OutputFormat': 'audio-24khz-48kbitrate-mono-mp3',
            },
            body: _buildSsml(text, voice, language),
          )
          .timeout(const Duration(milliseconds: edgeTtsTimeout));

      if (response.statusCode == 200) {
        await _writeToCache(cacheKey, response.bodyBytes);
        final path = _getCachePath(cacheKey);
        AppLogger.info('Edge TTS success: $text');
        return path;
      } else {
        AppLogger.warning('Edge TTS failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.warning('Edge TTS error: $e');
      return null;
    }
  }

  /// Azure TTS 语音合成
  Future<String?> _azureTtsSpeak(
    String text,
    String voice,
    String language,
  ) async {
    if (_azureApiKey == null || _azureRegion == null) {
      AppLogger.debug('Azure TTS not configured');
      return null;
    }

    try {
      final cacheKey = _getCacheKey(text, voice, language);

      // 检查缓存
      final cachedPath = await _readFromCache(cacheKey);
      if (cachedPath != null) {
        return cachedPath;
      }

      // 调用 Azure TTS API
      final url = 'https://$_azureRegion.tts.speech.microsoft.com'
          '/cognitiveservices/v1';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Ocp-Apim-Subscription-Key': _azureApiKey!,
              'Content-Type': 'application/ssml+xml',
              'X-Microsoft-OutputFormat': 'audio-24khz-48kbitrate-mono-mp3',
            },
            body: _buildSsml(text, voice, language),
          )
          .timeout(const Duration(milliseconds: azureTtsTimeout));

      if (response.statusCode == 200) {
        await _writeToCache(cacheKey, response.bodyBytes);
        final path = _getCachePath(cacheKey);
        AppLogger.info('Azure TTS success: $text');
        return path;
      } else {
        AppLogger.warning('Azure TTS failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.warning('Azure TTS error: $e');
      return null;
    }
  }

  /// 构建 SSML
  String _buildSsml(String text, String voice, String language) {
    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="$language">
  <voice name="$voice">$text</voice>
</speak>
''';
  }

  /// 三层降级策略：Edge TTS → Azure TTS → 返回 null（由调用方降级到系统 TTS）
  Future<bool> speak(
    String text, {
    String? voice,
    String language = 'zh-CN',
  }) async {
    if (text.trim().isEmpty) return false;

    // 默认语音
    final selectedVoice = voice ??
        (language == 'zh-CN' ? 'zh-CN-XiaoxiaoNeural' : 'en-US-JennyNeural');

    try {
      // 1. 尝试 Edge TTS
      final edgePath = await _edgeTtsSpeak(text, selectedVoice, language);
      if (edgePath != null) {
        await _playAudio(edgePath);
        return true;
      }

      // 2. 降级到 Azure TTS
      final azurePath = await _azureTtsSpeak(text, selectedVoice, language);
      if (azurePath != null) {
        await _playAudio(azurePath);
        return true;
      }

      // 3. 云 TTS 都失败，返回 false（调用方会降级到系统 TTS）
      AppLogger.warning('Cloud TTS failed, fallback to system TTS');
      return false;
    } catch (e) {
      AppLogger.error('Cloud TTS error', e);
      return false;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
