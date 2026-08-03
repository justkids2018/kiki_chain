import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../design_ui/kiki_ui_kit.dart';

class LocalAgreementPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const LocalAgreementPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<LocalAgreementPage> createState() => _LocalAgreementPageState();
}

class _LocalAgreementPageState extends State<LocalAgreementPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(const Color(0xFFF7EEDB))
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEDB),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: KikiUiColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF7EEDB),
        foregroundColor: KikiUiColors.textPrimary,
      ),
      body: SafeArea(
        top: false,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
