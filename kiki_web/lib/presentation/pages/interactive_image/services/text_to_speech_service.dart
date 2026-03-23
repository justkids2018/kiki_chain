import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_service.dart';
import '../../../../domain/entities/interactive_region.dart';

/// 内存音频源，将字节数据提供给 just_audio 播放
class _AudioBytesSource extends StreamAudioSource {
  final Uint8List _bytes;

  _AudioBytesSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

/// 使用微软 Edge TTS 的语音合成服务
///
/// 完全免费，无需 API 密钥，使用微软神经网络语音引擎
/// 支持儿童声音：中文小艺 + 英文Ana
/// 网络不可用时自动降级到系统 TTS
class TextToSpeechService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _fallbackTts = FlutterTts();
  AppSettingsService? _settings;
  bool _disposed = false;

  // 中文儿童声音：小艺（XiaoyiNeural）- 女童声
  static const String _chineseVoice = 'zh-CN-XiaoyiNeural';
  // 英文儿童声音：Ana - 女童声
  static const String _englishVoice = 'en-US-AnaNeural';

  // Edge TTS WebSocket 配置
  static const String _trustedClientToken =
      '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
  static const String _wsBaseUrl =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1';
  static const String _outputFormat = 'audio-24khz-48kbitrate-mono-mp3';

  TextToSpeechService();

  /// Initialize TTS（初始化 Edge TTS + 系统 TTS 降级方案）
  Future<void> initialize() async {
    try {
      // 初始化系统 TTS 作为降级方案
      await _fallbackTts.setSharedInstance(true);
      try {
        await _fallbackTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      } catch (_) {}
      await _fallbackTts.awaitSpeakCompletion(true);
      AppLogger.debug(
          'TTS initialized (Edge TTS primary, system TTS fallback)');
    } catch (e) {
      AppLogger.warning('Fallback TTS init failed', e);
    }
  }

  /// Speak the region's Chinese text and English text
  Future<void> speakRegion(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      await stop();

      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      // 说中文
      await _speakWithFallback(
        text: region.text,
        voice: _chineseVoice,
        lang: 'zh-CN',
        rate: rates['chinese']!,
      );

      // 说英文
      if (region.textEnglish.isNotEmpty) {
        await _speakWithFallback(
          text: region.textEnglish,
          voice: _englishVoice,
          lang: 'en-US',
          rate: rates['english']!,
        );
      }
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak pinyin pronunciation
  Future<void> speakPinyin(InteractiveRegion region) async {
    if (_disposed) return;
    try {
      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      await _speakWithFallback(
        text: region.textPinyin,
        voice: _chineseVoice,
        lang: 'zh-CN',
        rate: rates['chinese']!,
      );
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// Speak custom text
  Future<void> speak(String text, {String language = "en-US"}) async {
    if (_disposed) return;
    try {
      _settings ??= Get.isRegistered<AppSettingsService>()
          ? Get.find<AppSettingsService>()
          : null;
      final rates =
          _settings?.getSpeedRates() ?? {'chinese': 0.6, 'english': 0.7};

      final isChinese = language == "zh-CN" || language == "zh";
      await _speakWithFallback(
        text: text,
        voice: isChinese ? _chineseVoice : _englishVoice,
        lang: isChinese ? 'zh-CN' : 'en-US',
        rate: isChinese ? rates['chinese']! : rates['english']!,
      );
    } catch (e) {
      AppLogger.error('TTS error', e);
    }
  }

  /// 优先使用 Edge TTS，失败时降级到系统 TTS
  Future<void> _speakWithFallback({
    required String text,
    required String voice,
    required String lang,
    required double rate,
  }) async {
    if (text.trim().isEmpty || _disposed) return;

    try {
      // 尝试 Edge TTS
      final audioBytes = await _synthesize(text, voice, lang, rate);
      if (_disposed) return;
      if (audioBytes.isNotEmpty) {
        await _player
            .setAudioSource(_AudioBytesSource(Uint8List.fromList(audioBytes)));
        await _player.play();
        // 等待播放完成，但 dispose 时不阻塞
        await _player.playerStateStream
            .firstWhere(
              (state) => state.processingState == ProcessingState.completed,
            )
            .timeout(const Duration(seconds: 30), onTimeout: () {
          return _player.playerState;
        });
      }
    } catch (e) {
      // Edge TTS 失败，降级到系统 TTS
      AppLogger.warning('Edge TTS failed, falling back to system TTS', e);
      if (_disposed) return;
      await _speakWithSystemTts(text, lang, rate);
    }
  }

  /// 系统 TTS 降级播放
  Future<void> _speakWithSystemTts(
      String text, String lang, double rate) async {
    try {
      await _fallbackTts.setLanguage(lang);
      await _fallbackTts.setSpeechRate(rate);
      await _fallbackTts.speak(text);
    } catch (e) {
      AppLogger.error('System TTS fallback also failed', e);
    }
  }

  /// 通过 WebSocket 与 Edge TTS 交互，合成音频数据
  Future<List<int>> _synthesize(
    String text,
    String voice,
    String lang,
    double rate,
  ) async {
    final connectionId = const Uuid().v4().replaceAll('-', '');
    final requestId = const Uuid().v4().replaceAll('-', '');

    final url =
        '$_wsBaseUrl?TrustedClientToken=$_trustedClientToken&ConnectionId=$connectionId';

    WebSocket? ws;
    try {
      ws = await WebSocket.connect(
        url,
        headers: {
          'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0',
        },
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      AppLogger.warning('Edge TTS WebSocket connection failed', e);
      rethrow;
    }

    final audioData = <int>[];
    final completer = Completer<List<int>>();

    ws.listen(
      (message) {
        if (message is String) {
          if (message.contains('Path:turn.end')) {
            if (!completer.isCompleted) {
              completer.complete(audioData);
            }
          }
        } else if (message is List<int>) {
          // 二进制消息格式: 2字节头部长度 + 头部内容 + 音频数据
          if (message.length > 2) {
            final headerLength = (message[0] << 8) + message[1];
            final audioStart = 2 + headerLength;
            if (audioStart < message.length) {
              audioData.addAll(message.sublist(audioStart));
            }
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(audioData);
      },
    );

    // 1. 发送语音配置
    final timestamp = _getTimestamp();
    final configMessage = 'X-Timestamp:$timestamp\r\n'
        'Content-Type:application/json; charset=utf-8\r\n'
        'Path:speech.config\r\n\r\n'
        '{"context":{"synthesis":{"audio":{"metadataoptions":'
        '{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},'
        '"outputFormat":"$_outputFormat"}}}}';
    ws.add(configMessage);

    // 2. 发送 SSML
    final ssmlRate = _toSsmlRate(rate);
    final ssml =
        '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" '
        'xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="$lang">'
        '<voice name="$voice">'
        '<prosody rate="$ssmlRate">${_escapeXml(text)}</prosody>'
        '</voice></speak>';

    final ssmlMessage = 'X-RequestId:$requestId\r\n'
        'Content-Type:application/ssml+xml\r\n'
        'X-Timestamp:$timestamp\r\n'
        'Path:ssml\r\n\r\n'
        '$ssml';
    ws.add(ssmlMessage);

    // 3. 等待音频返回（10 秒超时，避免长时间阻塞 UI）
    try {
      final result =
          await completer.future.timeout(const Duration(seconds: 10));
      await ws.close();
      return result;
    } catch (e) {
      try {
        await ws.close();
      } catch (_) {}
      rethrow;
    }
  }

  /// ISO 8601 时间戳
  String _getTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }

  /// XML 特殊字符转义
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// 将 app 内部的速率 (0.0-1.0) 转换为 SSML prosody rate 字符串
  String _toSsmlRate(double appRate) {
    // appRate 0.5 = 慢, 0.7 = 正常, 1.0 = 快
    final percentage = ((appRate - 0.7) * 100).round();
    if (percentage >= 0) return '+$percentage%';
    return '$percentage%';
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _player.stop();
      await _fallbackTts.stop();
    } catch (e) {
      AppLogger.warning('TTS stop error', e);
    }
  }

  /// Dispose TTS resources
  void dispose() {
    _disposed = true;
    _player.dispose();
    _fallbackTts.stop();
  }
}
