import 'package:flutter/material.dart';

Widget createAnimatedSvgWidget(String assetPath, {double? width, double? height}) {
  return SizedBox(
    width: width,
    height: height,
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
