/// TTS 提供商抽象接口
///
/// 定义所有 TTS 提供商必须实现的方法
abstract class TTSProvider {
  /// 初始化 TTS 服务
  Future<void> initialize();

  /// 合成语音
  ///
  /// [text] 要合成的文本
  /// [language] 语言代码 (zh-CN, en-US)
  /// [speed] 语速 (0.5 - 2.0)
  /// [pitch] 音调 (-500 到 500)
  /// [emotion] 情感类型
  ///
  /// 返回音频字节数据
  Future<List<int>> synthesize({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  });

  /// 检查服务是否可用
  Future<bool> isAvailable();

  /// 获取提供商名称
  String get providerName;

  /// 释放资源
  Future<void> dispose();
}

/// TTS 情感类型
enum TTSEmotion {
  neutral,    // 中性
  happy,      // 开心
  excited,    // 兴奋
  gentle,     // 温柔
  encouraging, // 鼓励
}

/// TTS 配置
class TTSConfig {
  /// Kiki 中文声音
  final String voiceNameZh;

  /// Kiki 英文声音
  final String voiceNameEn;

  /// 默认语速
  final double defaultSpeed;

  /// 默认音调
  final double defaultPitch;

  /// 是否启用缓存
  final bool enableCache;

  /// 缓存过期时间（天）
  final int cacheExpirationDays;

  const TTSConfig({
    required this.voiceNameZh,
    required this.voiceNameEn,
    this.defaultSpeed = 1.0,
    this.defaultPitch = 0.0,
    this.enableCache = true,
    this.cacheExpirationDays = 30,
  });
}
