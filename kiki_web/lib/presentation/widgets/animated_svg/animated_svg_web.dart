// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  String? _viewType;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _loadSvg();
    }
  }

  Future<void> _loadSvg() async {
    try {
      final svgString = await rootBundle.loadString(widget.assetPath);
      final base64Svg = base64Encode(utf8.encode(svgString));
      final dataUri = 'data:image/svg+xml;base64,$base64Svg';
      
      final viewType = 'animated-svg-${widget.assetPath.hashCode}-${dataUri.hashCode}';
      
      // Register the view factory for web using inline SVG to support local references (gradients/filters)
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        var processedSvg = svgString;
        // Adjust SVG to scale dynamically with the parent container
        processedSvg = processedSvg.replaceFirst('width="720"', 'width="100%"');
        processedSvg = processedSvg.replaceFirst('height="240"', 'height="100%"');
        
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
        });
      }
    } catch (e) {
      debugPrint('Error loading animated SVG: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If animate is false, render statically using flutter_svg
    if (!widget.animate) {
      return SvgPicture.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
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

    if (_viewType == null) {
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

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RepaintBoundary(
        child: HtmlElementView(viewType: _viewType!),
      ),
    );
  }
}
