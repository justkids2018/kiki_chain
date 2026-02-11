import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'tts_provider.dart';

/// 阿里云 TTS 提供商
///
/// 使用阿里云智能语音服务进行语音合成
/// 文档: https://help.aliyun.com/document_detail/84435.html
class AliyunTTSProvider implements TTSProvider {
  final String accessKeyId;
  final String accessKeySecret;
  final String region;
  final TTSConfig config;

  // 阿里云 TTS API 端点
  static const String _endpoint = 'nls-gateway-cn-shanghai.aliyuncs.com';
  static const String _apiVersion = '2019-02-28';

  AliyunTTSProvider({
    required this.accessKeyId,
    required this.accessKeySecret,
    this.region = 'cn-shanghai',
    required this.config,
  });

  @override
  String get providerName => 'Aliyun TTS';

  @override
  Future<void> initialize() async {
    // 验证配置
    if (accessKeyId.isEmpty || accessKeySecret.isEmpty) {
      throw Exception('阿里云 TTS 配置无效：缺少 AccessKey');
    }

    // 测试连接
    final available = await isAvailable();
    if (!available) {
      throw Exception('阿里云 TTS 服务不可用');
    }

    print('✅ 阿里云 TTS 初始化成功');
  }

  @override
  Future<List<int>> synthesize({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  }) async {
    try {
      // 选择声音
      final voiceName = _selectVoice(language, emotion);

      // 构建请求参数
      final params = {
        'Text': text,
        'Voice': voiceName,
        'Format': 'mp3',
        'SampleRate': '16000',
        'Volume': '50',
        'SpeechRate': _convertSpeed(speed).toString(),
        'PitchRate': _convertPitch(pitch).toString(),
      };

      // 发送请求
      final response = await _sendRequest(params);

      if (response.statusCode == 200) {
        // 阿里云返回的是 JSON，包含 base64 编码的音频
        final jsonData = json.decode(response.body);
        if (jsonData['Code'] == '200') {
          final audioBase64 = jsonData['AudioData'];
          return base64.decode(audioBase64);
        } else {
          throw Exception('阿里云 TTS 错误: ${jsonData['Message']}');
        }
      } else {
        throw Exception('阿里云 TTS 请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 阿里云 TTS 合成失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 发送一个简单的测试请求
      final testParams = {
        'Text': '测试',
        'Voice': config.voiceNameZh,
        'Format': 'mp3',
      };

      final response = await _sendRequest(testParams);
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ 阿里云 TTS 不可用: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    // 清理资源（如果需要）
    print('🔄 阿里云 TTS 资源已释放');
  }

  /// 选择合适的声音
  String _selectVoice(String language, TTSEmotion emotion) {
    // 根据语言选择基础声音
    String baseVoice = language.startsWith('zh')
        ? config.voiceNameZh
        : config.voiceNameEn;

    // 阿里云支持的儿童友好声音
    // 中文: xiaoyun (温柔女声), xiaogang (活泼男童声)
    // 英文: Wendy (美式女声), Catherine (英式女声)

    // 根据情感微调（如果需要）
    if (language.startsWith('zh')) {
      switch (emotion) {
        case TTSEmotion.excited:
        case TTSEmotion.happy:
          return 'xiaogang'; // 活泼男童声
        case TTSEmotion.gentle:
        case TTSEmotion.encouraging:
          return 'xiaoyun'; // 温柔女声
        default:
          return baseVoice;
      }
    }

    return baseVoice;
  }

  /// 转换语速（Flutter 1.0 = 阿里云 0）
  int _convertSpeed(double speed) {
    // Flutter: 0.5-2.0 -> 阿里云: -500 到 500
    return ((speed - 1.0) * 500).round();
  }

  /// 转换音调
  int _convertPitch(double pitch) {
    // 直接使用，范围 -500 到 500
    return pitch.round();
  }

  /// 发送 HTTP 请求到阿里云
  Future<http.Response> _sendRequest(Map<String, String> params) async {
    // 添加公共参数
    final allParams = {
      ...params,
      'Action': 'SynthesizeSpeech',
      'Version': _apiVersion,
      'Format': 'JSON',
      'RegionId': region,
      'AccessKeyId': accessKeyId,
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'SignatureNonce': _generateNonce(),
      'Timestamp': _getTimestamp(),
    };

    // 生成签名
    final signature = _generateSignature(allParams);
    allParams['Signature'] = signature;

    // 构建 URL
    final uri = Uri.https(_endpoint, '/stream/v1/tts', allParams);

    // 发送请求
    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// 生成签名
  String _generateSignature(Map<String, String> params) {
    // 1. 参数排序
    final sortedKeys = params.keys.toList()..sort();

    // 2. 构建待签名字符串
    final canonicalizedQueryString = sortedKeys
        .map((key) => '${_percentEncode(key)}=${_percentEncode(params[key]!)}')
        .join('&');

    final stringToSign = 'POST&${_percentEncode('/')}&${_percentEncode(canonicalizedQueryString)}';

    // 3. 计算签名
    final key = utf8.encode('$accessKeySecret&');
    final bytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(bytes);

    return base64.encode(digest.bytes);
  }

  /// URL 编码
  String _percentEncode(String value) {
    return Uri.encodeComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  /// 生成随机数
  String _generateNonce() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// 获取时间戳
  String _getTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }
}
