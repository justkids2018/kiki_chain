import 'package:flutter_tts/flutter_tts.dart';
import 'tts_provider.dart';

/// 系统 TTS 提供商（保底方案）
///
/// 使用设备自带的 TTS 引擎
/// 优点：免费、离线、零延迟
/// 缺点：音质一般、不同设备差异大
class SystemTTSProvider implements TTSProvider {
  final FlutterTts _flutterTts = FlutterTts();
  final TTSConfig config;

  bool _isInitialized = false;

  SystemTTSProvider({required this.config});

  @override
  String get providerName => 'System TTS';

  @override
  Future<void> initialize() async {
    try {
      // 配置 TTS
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(config.defaultSpeed);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.2); // 稍高音调，更适合儿童

      // iOS 特定配置
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _isInitialized = true;
      print('✅ 系统 TTS 初始化成功');
    } catch (e) {
      print('❌ 系统 TTS 初始化失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<int>> synthesize({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  }) async {
    // 系统 TTS 不返回音频字节，直接播放
    // 这里返回空数组表示使用直接播放模式
    throw UnsupportedError(
      '系统 TTS 不支持音频字节生成，请使用 speakDirectly() 方法',
    );
  }

  /// 直接播放（系统 TTS 专用方法）
  Future<void> speakDirectly({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 设置语言
      await _flutterTts.setLanguage(language);

      // 设置语速
      await _flutterTts.setSpeechRate(speed * config.defaultSpeed);

      // 设置音调（根据情感调整）
      final emotionPitch = _getEmotionPitch(emotion);
      await _flutterTts.setPitch(1.0 + pitch / 100 + emotionPitch);

      // 播放
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ 系统 TTS 播放失败: $e');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// 暂停播放
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 检查是否有可用的语音
      final languages = await _flutterTts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await _flutterTts.stop();
    print('🔄 系统 TTS 资源已释放');
  }

  /// 获取情感对应的音调调整
  double _getEmotionPitch(TTSEmotion emotion) {
    switch (emotion) {
      case TTSEmotion.excited:
        return 0.3; // 兴奋：高音调
      case TTSEmotion.happy:
        return 0.2; // 开心：稍高
      case TTSEmotion.gentle:
        return -0.1; // 温柔：稍低
      case TTSEmotion.encouraging:
        return 0.15; // 鼓励：稍高
      default:
        return 0.0;
    }
  }

  /// 获取可用语言列表
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// 获取可用声音列表
  Future<List<String>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }
}
