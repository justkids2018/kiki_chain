import 'package:flutter/material.dart';

/// 内联 3 星进度指示器
///
/// 放置于"互动学习"标题行右侧。
/// - 灰色圆角背景，无模糊，无发散光晕
/// - 金色实心 vs 浅灰描边，清晰紧凑
/// - [starKeys] 每颗星的 GlobalKey，供飞翔动画精确定位目标坐标
class InlineStarBar extends StatelessWidget {
  final int starsEarned;
  static const int maxStars = 3;

  final List<GlobalKey> starKeys;

  const InlineStarBar({
    Key? key,
    required this.starsEarned,
    required this.starKeys,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxStars, (index) {
          final earned = index < starsEarned;
          return SizedBox(
            key: starKeys[index],
            width: 22,
            height: 22,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                key: ValueKey('star_${index}_$earned'),
                earned ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: earned
                    ? const Color(0xFFFFB800) // 清晰饱和金色
                    : const Color(0xFFBBBBBB), // 浅灰描边
              ),
            ),
          );
        }),
      ),
    );
  }
}
