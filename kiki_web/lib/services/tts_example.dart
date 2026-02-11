import 'package:flutter/material.dart';
import 'tts/kiki_tts_service.dart';
import 'tts/tts_provider.dart';

/// TTS 使用示例
class TTSExample extends StatefulWidget {
  const TTSExample({Key? key}) : super(key: key);

  @override
  State<TTSExample> createState() => _TTSExampleState();
}

class _TTSExampleState extends State<TTSExample> {
  late KikiTTSService _ttsService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    // 配置 Kiki 的声音
    final config = TTSConfig(
      voiceNameZh: 'xiaoyun', // 阿里云温柔女声
      voiceNameEn: 'Wendy',   // 阿里云美式女声
      defaultSpeed: 0.9,      // 稍慢，适合儿童
      defaultPitch: 50.0,     // 稍高音调，可爱
      enableCache: true,
      cacheExpirationDays: 30,
    );

    _ttsService = KikiTTSService(config: config);

    // 初始化（从环境变量或配置文件读取密钥）
    await _ttsService.initialize(
      aliyunAccessKeyId: 'YOUR_ALIYUN_ACCESS_KEY_ID',
      aliyunAccessKeySecret: 'YOUR_ALIYUN_ACCESS_KEY_SECRET',
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki TTS 测试'),
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
        // 基础测试
        _buildSection(
          title: '基础测试',
          children: [
            _buildButton(
              '中文问候',
              () => _ttsService.speak(
                '你好呀！我是 Kiki，我们一起探险吧！',
                language: 'zh-CN',
                emotion: TTSEmotion.happy,
              ),
            ),
            _buildButton(
              '英文问候',
              () => _ttsService.speak(
                'Hello! I am Kiki. Let\'s explore together!',
                language: 'en-US',
                emotion: TTSEmotion.happy,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 情感测试
        _buildSection(
          title: '情感测试',
          children: [
            _buildButton(
              '开心',
              () => _ttsService.speak(
                '太棒了！你真聪明！',
                emotion: TTSEmotion.happy,
              ),
            ),
            _buildButton(
              '兴奋',
              () => _ttsService.speak(
                '哇！你学得真快！',
                emotion: TTSEmotion.excited,
              ),
            ),
            _buildButton(
              '温柔',
              () => _ttsService.speak(
                '没关系，慢慢来',
                emotion: TTSEmotion.gentle,
              ),
            ),
            _buildButton(
              '鼓励',
              () => _ttsService.speak(
                '加油！你可以的！',
                emotion: TTSEmotion.encouraging,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 场景测试
        _buildSection(
          title: '场景对话',
          children: [
            _buildButton(
              '日常生活',
              () => _speakSceneDialogue('daily_life'),
            ),
            _buildButton(
              '游乐场',
              () => _speakSceneDialogue('playground'),
            ),
            _buildButton(
              '数字学习',
              () => _speakSceneDialogue('numbers'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 控制按钮
        _buildSection(
          title: '播放控制',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _ttsService.pause(),
                  icon: const Icon(Icons.pause),
                  label: const Text('暂停'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _ttsService.resume(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('继续'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _ttsService.stop(),
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 缓存管理
        _buildSection(
          title: '缓存管理',
          children: [
            _buildButton(
              '查看缓存统计',
              () async {
                final stats = await _ttsService.getCacheStats();
                _showDialog('缓存统计', stats.toString());
              },
            ),
            _buildButton(
              '清空缓存',
              () async {
                await _ttsService.clearCache();
                _showDialog('提示', '缓存已清空');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }

  Future<void> _speakSceneDialogue(String scene) async {
    switch (scene) {
      case 'daily_life':
        await _ttsService.speak(
          '欢迎来到日常生活场景！',
          emotion: TTSEmotion.happy,
        );
        await Future.delayed(const Duration(seconds: 2));
        await _ttsService.speak(
          '你看，这是什么？',
          emotion: TTSEmotion.neutral,
        );
        break;

      case 'playground':
        await _ttsService.speak(
          '哇！游乐场好好玩呀！',
          emotion: TTSEmotion.excited,
        );
        await Future.delayed(const Duration(seconds: 2));
        await _ttsService.speak(
          '你想玩旋转木马吗？',
          emotion: TTSEmotion.happy,
        );
        break;

      case 'numbers':
        await _ttsService.speak(
          '我们一起学数字吧！',
          emotion: TTSEmotion.encouraging,
        );
        await Future.delayed(const Duration(seconds: 2));
        await _ttsService.speak(
          '这是数字 1，one！',
          emotion: TTSEmotion.neutral,
        );
        break;
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
