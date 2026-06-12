import 'dart:ui';
import 'package:flutter/material.dart';

/// 内联 3 星进度指示器
///
/// 放置于"互动学习"标题行右侧。
/// - 外层 Container 承载阴影，实现“浮起来”的立体感（不被 ClipRRect 裁剪）
/// - 内层 ClipRRect + BackdropFilter 实现灰色毛玻璃效果
/// - 金色 3D 渐变星 vs 描边星，立体饱满
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
      // 外层阴影，使毛玻璃“浮起来”
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              // 灰色毛玻璃色调（使用灰蓝色系半透明）
              color: const Color(0xFFE2E8F0).withOpacity(0.6), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
                width: 1.2,
              ),
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
                    child: earned
                        ? _GradientStarIcon(
                            key: ValueKey('star_${index}_on'),
                            icon: Icons.star_rounded,
                            size: 20,
                          )
                        : _EmptyStarIcon(
                            key: ValueKey('star_${index}_off'),
                            icon: Icons.star_outline_rounded,
                            size: 20,
                          ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3D 渐变金色星星组件
class _GradientStarIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _GradientStarIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEA79), // 亮金顶光
            Color(0xFFFFB800), // 饱满金黄
            Color(0xFFE58F00), // 底部暗金阴影
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // ShaderMask 遮罩基色必须为白色
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 1.5),
            blurRadius: 1.5,
          ),
          Shadow(
            color: const Color(0xFFFFD700).withOpacity(0.35),
            offset: Offset.zero,
            blurRadius: 4.0,
          ),
        ],
      ),
    );
  }
}

/// 优雅的空心/未获得星星组件
class _EmptyStarIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _EmptyStarIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: Colors.black.withOpacity(0.18), // 柔和半透明描边
      shadows: [
        Shadow(
          color: Colors.white.withOpacity(0.8),
          offset: const Offset(0, 1),
          blurRadius: 1.0,
        ),
      ],
    );
  }
}
