// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SvgAnimationType {
  none,
  float,
  pulse,
}

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
  String? _viewType;
  String? _svgContent;
  bool _isLoading = true;
  bool _hasError = false;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
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
      final svgString = await rootBundle.loadString(widget.assetPath);
      
      var processedSvg = svgString;
      // Adjust SVG to scale dynamically with the parent container
      processedSvg = processedSvg.replaceFirst(RegExp(r'width="[0-9.]+"'), 'width="100%"');
      processedSvg = processedSvg.replaceFirst(RegExp(r'height="[0-9.]+"'), 'height="100%"');

      final useWebView = widget.animate && widget.animationType == SvgAnimationType.none;

      if (!useWebView) {
        // Strip out drop shadows (both XML attributes & CSS style properties) and animations
        // so flutter_svg can parse colors and gradients natively without rendering gray/black fallbacks
        processedSvg = processedSvg.replaceAll(RegExp(r'filter\s*=\s*"url\([^)]+\)"'), '');
        processedSvg = processedSvg.replaceAll(RegExp(r'filter\s*:\s*url\([^)]+\);?'), '');
        processedSvg = processedSvg.replaceAll(RegExp(r'animation\s*:\s*[^;]+;?'), '');
      }

      // Cache processed SVG content for native rendering
      _svgContent = processedSvg;

      if (useWebView) {
        final base64Svg = base64Encode(utf8.encode(processedSvg));
        final dataUri = 'data:image/svg+xml;base64,$base64Svg';
        final viewType = 'animated-svg-${widget.assetPath.hashCode}-${dataUri.hashCode}';
        
        // Register the view factory for web using inline SVG to support local references (gradients/filters)
        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          final div = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'flex'
            ..style.justifyContent = 'center'
            ..style.alignItems = 'center';
            
          div.setInnerHtml(
            processedSvg,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );
          return div;
        });

        if (mounted) {
          setState(() {
            _viewType = viewType;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading animated SVG: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
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

    if (_hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Text(
            'Hi Kiki',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7CB342),
            ),
          ),
        ),
      );
    }

    // If full HTML animation is requested (animate is true, animationType is none)
    if (widget.animate && widget.animationType == SvgAnimationType.none && _viewType != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: RepaintBoundary(
          child: HtmlElementView(viewType: _viewType!),
        ),
      );
    }

    // Default static or native animation rendering
    if (_svgContent == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.error_outline, color: Colors.red),
      );
    }

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
