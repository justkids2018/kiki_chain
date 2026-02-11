import 'package:flutter/material.dart';
import 'tts/kiki_tts_service.dart';
import 'tts/tts_provider.dart';
import 'tts/aliyun_tts_provider.dart';
import 'tts/system_tts_provider.dart';

/// TTS 使用示例 - 简化版
///
/// 展示如何使用依赖注入模式配置 TTS 服务
class SimpleTTSExample extends StatefulWidget {
  const SimpleTTSExample({Key? key}) : super(key: key);

  @override
  State<SimpleTTSExample> createState() => _SimpleTTSExampleState();
}

class _SimpleTTSExampleState extends State<SimpleTTSExample> {
  late KikiTTSService _ttsService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    // 方式 1: 使用阿里云 TTS（推荐）
    final provider = await _createAliyunProvider();

    // 方式 2: 使用系统 TTS（保底）
    // final provider = await _createSystemProvider();

    // 创建服务（依赖注入）
    _ttsService = KikiTTSService(
      provider: provider,
      enableCache: true,
      cacheExpirationDays: 30,
    );

    // 初始化
    await _ttsService.initialize();

    setState(() {
      _isInitialized = true;
    });
  }

  /// 创建阿里云 TTS 提供商
  Future<TTSProvider> _createAliyunProvider() async {
    final config = TTSConfig(
      voiceNameZh: 'xiaoyun',  // 温柔女声
      voiceNameEn: 'Wendy',    // 美式女声
      defaultSpeed: 0.9,
      defaultPitch: 50.0,
    );

    return AliyunTTSProvider(
      accessKeyId: 'YOUR_ACCESS_KEY_ID',
      accessKeySecret: 'YOUR_ACCESS_KEY_SECRET',
      config: config,
    );
  }

  /// 创建系统 TTS 提供商
  Future<TTSProvider> _createSystemProvider() async {
    final config = TTSConfig(
      voiceNameZh: 'zh-CN',
      voiceNameEn: 'en-US',
      defaultSpeed: 0.9,
      defaultPitch: 0.0,
    );

    return SystemTTSProvider(config: config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki TTS - 简化版'),
      ),
      body: _isInitialized
          ? _buildContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildButton(
          '中文问候',
          () => _ttsService.speak('你好呀！我是 Kiki！'),
        ),
        _buildButton(
          '英文问候',
          () => _ttsService.speak(
            'Hello! I am Kiki!',
            language: 'en-US',
          ),
        ),
        _buildButton(
          '开心情感',
          () => _ttsService.speak(
            '太棒了！你真聪明！',
            emotion: TTSEmotion.happy,
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _ttsService.pause(),
              child: const Text('暂停'),
            ),
            ElevatedButton(
              onPressed: () => _ttsService.resume(),
              child: const Text('继续'),
            ),
            ElevatedButton(
              onPressed: () => _ttsService.stop(),
              child: const Text('停止'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

/// TTS 提供商工厂
///
/// 根据环境自动选择最佳提供商
class TTSProviderFactory {
  /// 创建 TTS 提供商（带降级策略）
  static Future<TTSProvider> create({
    String? aliyunAccessKeyId,
    String? aliyunAccessKeySecret,
  }) async {
    final config = TTSConfig(
      voiceNameZh: 'xiaoyun',
      voiceNameEn: 'Wendy',
      defaultSpeed: 0.9,
      defaultPitch: 50.0,
    );

    // 尝试使用阿里云 TTS
    if (aliyunAccessKeyId != null && aliyunAccessKeySecret != null) {
      try {
        final provider = AliyunTTSProvider(
          accessKeyId: aliyunAccessKeyId,
          accessKeySecret: aliyunAccessKeySecret,
          config: config,
        );

        if (await provider.isAvailable()) {
          print('✅ 使用阿里云 TTS');
          return provider;
        }
      } catch (e) {
        print('⚠️ 阿里云 TTS 不可用: $e');
      }
    }

    // 降级到系统 TTS
    print('⚠️ 降级到系统 TTS');
    return SystemTTSProvider(config: config);
  }
}
