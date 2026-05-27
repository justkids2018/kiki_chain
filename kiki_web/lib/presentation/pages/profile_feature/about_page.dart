import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String _contactEmail = 'qishoudong@163.com';
  String _versionText = '--';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionText = info.version;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _versionText = '1.0.1';
      });
    }
  }

  Future<void> _openMailClient() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
    );

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showHint('未检测到可用邮箱客户端');
      }
    } catch (_) {
      if (!mounted) return;
      _showHint('打开邮箱失败，请稍后重试');
    }
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: _contactEmail));
    if (!mounted) return;
    _showHint('邮箱已复制：$_contactEmail');
  }

  void _showHint(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(message), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _AboutSummaryCard(
            versionText: _versionText,
            contactEmail: _contactEmail,
            onEmailTap: _openMailClient,
            onEmailLongPress: _copyEmail,
          ),
        ],
      ),
    );
  }
}

class _AboutSummaryCard extends StatelessWidget {
  final String versionText;
  final String contactEmail;
  final VoidCallback onEmailTap;
  final VoidCallback onEmailLongPress;

  const _AboutSummaryCard({
    required this.versionText,
    required this.contactEmail,
    required this.onEmailTap,
    required this.onEmailLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFF6EFE5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Hi Kiki',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2A27),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '版本 $versionText',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A7E71),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFECE4D9)),
          const SizedBox(height: 16),
          const Text(
            'Hi Kiki 通过场景认词、规范笔画与书写练习，帮助孩子把词汇理解和写字能力一起练起来。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF5E544B),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onEmailTap,
            onLongPress: onEmailLongPress,
            child: Text(
              '有任何建议欢迎联系我们：$contactEmail',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF7A6F63),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF7A6F63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
