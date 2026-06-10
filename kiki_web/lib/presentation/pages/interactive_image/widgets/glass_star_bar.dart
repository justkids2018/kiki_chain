import 'dart:ui';
import 'package:flutter/material.dart';

/// 毛玻璃效果的 3 星进度栏
///
/// 用法：
/// ```dart
/// GlassStarBar(starsEarned: 2, starKeys: _starKeys)
/// ```
/// [starKeys] 用于外部获取每颗星星的全局坐标（飞翔动画目标点）。
class GlassStarBar extends StatelessWidget {
  final int starsEarned;
  static const int maxStars = 3;

  /// 每颗星星的 GlobalKey，供飞翔动画定位目标坐标
  final List<GlobalKey> starKeys;

  const GlassStarBar({
    Key? key,
    required this.starsEarned,
    required this.starKeys,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            // 毛玻璃基底：白色半透明
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxStars, (index) {
              final earned = index < starsEarned;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _StarItem(
                  starKey: starKeys[index],
                  earned: earned,
                  index: index,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _StarItem extends StatelessWidget {
  final GlobalKey starKey;
  final bool earned;
  final int index;

  const _StarItem({
    required this.starKey,
    required this.earned,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: SizedBox(
        key: ValueKey('star_${index}_${earned ? 'on' : 'off'}'),
        width: 26,
        height: 26,
        child: earned ? _EarnedStar(starKey: starKey) : _EmptyStar(starKey: starKey),
      ),
    );
  }
}

class _EarnedStar extends StatelessWidget {
  final GlobalKey starKey;

  const _EarnedStar({required this.starKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: starKey,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.55),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.star_rounded,
        size: 26,
        color: Color(0xFFFFD700),
      ),
    );
  }
}

class _EmptyStar extends StatelessWidget {
  final GlobalKey starKey;

  const _EmptyStar({required this.starKey});

  @override
  Widget build(BuildContext context) {
    return Icon(
      key: starKey,
      Icons.star_border_rounded,
      size: 26,
      color: Colors.white.withValues(alpha: 0.75),
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 4,
        ),
      ],
    );
  }
}
