// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createAnimatedSvgWidget(String assetPath, {double? width, double? height}) {
  final viewType = 'animated-svg-${assetPath.hashCode}';
  
  // Register the view factory for web
  // We use ImageElement to render SVG natively in the browser so that CSS keyframe animations run.
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    return html.ImageElement()
      ..src = 'assets/$assetPath'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.display = 'block';
  });
  
  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
