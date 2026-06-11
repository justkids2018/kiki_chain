import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum SvgAnimationType {
  none,
  float,
  pulse,
}

/// A reusable, encapsulated widget that displays any animated SVG.
///
/// On iOS and Android, it utilizes a transparent WebView to run the SVG's native CSS keyframe animations.
/// On Web and Desktop, it falls back to a static SvgPicture to prevent crashes and ensure compatibility.
class AnimatedSvgWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool animate;
  final SvgAnimationType animationType;

  const AnimatedSvgWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.animate = false,
    this.animationType = SvgAnimationType.none,
  }) : super(key: key);

  @override
  State<AnimatedSvgWidget> createState() => _AnimatedSvgWidgetState();
}

class _AnimatedSvgWidgetState extends State<AnimatedSvgWidget> with SingleTickerProviderStateMixin {
  WebViewController? _webViewController;
  String? _svgContent;
  bool _isLoading = true;
  bool _isMobile = false;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    // Check if the current platform is mobile native
    _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    _loadSvg();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedSvgWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate ||
        widget.animationType != oldWidget.animationType ||
        widget.assetPath != oldWidget.assetPath) {
      _animationController?.dispose();
      _animationController = null;
      _animation = null;
      _initAnimation();
      if (widget.assetPath != oldWidget.assetPath) {
        _isLoading = true;
        _loadSvg();
      }
    }
  }

  void _initAnimation() {
    if (!widget.animate || widget.animationType == SvgAnimationType.none) {
      return;
    }

    if (widget.animationType == SvgAnimationType.pulse) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1800),
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
      );
    } else if (widget.animationType == SvgAnimationType.float) {
      // For titles, float displacement is larger. For buttons, it is smaller.
      final isLogo = widget.assetPath.contains('title');
      final double startVal = isLogo ? 4.0 : 1.5;
      final double endVal = isLogo ? -4.0 : -1.5;

      _animationController = AnimationController(
        duration: const Duration(milliseconds: 2400), // 稍微加快周期，动效更灵动
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: startVal, end: endVal).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadSvg() async {
    try {
      final svg = await rootBundle.loadString(widget.assetPath);
      
      // Make sure the SVG scales dynamically to fit the WebView container
      var processedSvg = svg;
      processedSvg = processedSvg.replaceFirst(RegExp(r'width="[0-9.]+"'), 'width="100%"');
      processedSvg = processedSvg.replaceFirst(RegExp(r'height="[0-9.]+"'), 'height="100%"');

      final useWebView = widget.animate && widget.animationType == SvgAnimationType.none && _isMobile;

      if (!useWebView) {
        // Strip out drop shadows (both XML attributes & CSS style properties) and animations
        // so flutter_svg can parse colors and gradients natively without rendering gray/black fallbacks
        processedSvg = processedSvg.replaceAll(RegExp(r'filter\s*=\s*"url\([^)]+\)"'), '');
        processedSvg = processedSvg.replaceAll(RegExp(r'filter\s*:\s*url\([^)]+\);?'), '');
        processedSvg = processedSvg.replaceAll(RegExp(r'animation\s*:\s*[^;]+;?'), '');
      }

      if (mounted) {
        setState(() {
          _svgContent = processedSvg;
          _isLoading = false;
        });
        
        // Only run WebView on mobile if we request full CSS animation (animate is true, animationType is none)
        if (useWebView) {
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

    // On Mobile (iOS / Android), render using transparent WebView to run the CSS animations if requested (animationType == none)
    if (widget.animate && widget.animationType == SvgAnimationType.none && _isMobile && _webViewController != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: RepaintBoundary(
          child: WebViewWidget(controller: _webViewController!),
        ),
      );
    }

    // Default: render using static/processed SvgPicture string
    Widget svgWidget = SvgPicture.string(
      _svgContent!,
      width: widget.width,
      height: widget.height,
    );

    // Apply native Flutter animations if requested
    if (widget.animate && _animation != null) {
      if (widget.animationType == SvgAnimationType.pulse) {
        svgWidget = ScaleTransition(
          scale: _animation!,
          child: svgWidget,
        );
      } else if (widget.animationType == SvgAnimationType.float) {
        svgWidget = AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation!.value),
              child: child,
            );
          },
          child: svgWidget,
        );
      }
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: svgWidget,
    );
  }
}
