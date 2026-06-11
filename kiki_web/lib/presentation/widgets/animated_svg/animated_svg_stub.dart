import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A reusable, encapsulated widget that displays any animated SVG.
///
/// On iOS and Android, it utilizes a transparent WebView to run the SVG's native CSS keyframe animations.
/// On Web and Desktop, it falls back to a static SvgPicture to prevent crashes and ensure compatibility.
class AnimatedSvgWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool animate;

  const AnimatedSvgWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.animate = false,
  }) : super(key: key);

  @override
  State<AnimatedSvgWidget> createState() => _AnimatedSvgWidgetState();
}

class _AnimatedSvgWidgetState extends State<AnimatedSvgWidget> {
  WebViewController? _webViewController;
  String? _svgContent;
  bool _isLoading = true;
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    // Check if the current platform is mobile native
    _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (widget.animate) {
      _loadSvg();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadSvg() async {
    try {
      final svg = await rootBundle.loadString(widget.assetPath);
      
      // Make sure the SVG scales dynamically to fit the WebView container
      var processedSvg = svg;
      processedSvg = processedSvg.replaceFirst(RegExp(r'width="[0-9.]+"'), 'width="100%"');
      processedSvg = processedSvg.replaceFirst(RegExp(r'height="[0-9.]+"'), 'height="100%"');

      if (mounted) {
        setState(() {
          _svgContent = processedSvg;
          _isLoading = false;
        });
        
        if (_isMobile) {
          _initWebViewController(processedSvg);
        }
      }
    } catch (e) {
      debugPrint('Error loading SVG asset: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initWebViewController(String svgContent) {
    // Standard HTML layout with Google Fonts imported to display plump/rounded fonts
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@300..700&family=Nunito:wght@200..900&display=swap');
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: transparent;
    }
    svg {
      width: 100%;
      height: 100%;
      display: block;
    }
  </style>
</head>
<body>
  $svgContent
</body>
</html>
''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString(htmlContent);

    setState(() {
      _webViewController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If animate is false, render statically and synchronously using flutter_svg
    if (!widget.animate) {
      return SvgPicture.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
      );
    }

    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_svgContent == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.error_outline, color: Colors.red),
      );
    }

    // On Mobile (iOS / Android), render using transparent WebView to run the CSS animations
    if (_isMobile && _webViewController != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: RepaintBoundary(
          child: WebViewWidget(controller: _webViewController!),
        ),
      );
    }

    // On other platforms (Desktop macOS/Windows, or fallback), render statically using flutter_svg
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SvgPicture.string(
        _svgContent!,
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
