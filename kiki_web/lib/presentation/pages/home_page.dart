import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../widgets/profile_tab.dart';
import '../widgets/animated_svg/animated_svg.dart';
import '../widgets/glass_back_button.dart';
import '../controllers/auth_controller.dart';
import 'interactive_image_home/interactive_image_home_page.dart';
import 'learning_record/learning_record_page.dart';

/// 主页面
///
/// 包含底部导航栏的主页面，支持多个 Tab 切换
/// Tab 1: 互动图片首页
/// Tab 2: 个人中心
///
/// Created: January 27, 2026
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const InteractiveImageHomePage(),
          Positioned(
            top: media.padding.top + 6, // 顶部上移至 6dp，减少上方留空
            left: media.padding.left -
                5, // 抵消 SVG 内部左侧 15dp 空白，使 LOGO 视觉边缘距离屏幕左边刚好 10dp
            right: media.padding.right + 10, // 使右侧按钮组距离屏幕右边刚好 10dp
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧 LOGO 标题
                const AnimatedSvgWidget(
                  assetPath: 'assets/images/hi_kiki_title_animated.svg',
                  width: 240,
                  height: 80,
                  animate: false,
                  animationType: SvgAnimationType.none,
                ),
                // 右侧按钮组（保持垂直居中对齐）
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStarStatusButton(context),
                    const SizedBox(width: 15),
                    _buildSvgButton(
                      assetPath:
                          'assets/images/hi_kiki_learning_record_button.svg',
                      onTap: () {
                        Get.to(() => const LearningRecordPage());
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildSvgButton(
                      assetPath: 'assets/images/hi_kiki_profile_button.svg',
                      onTap: () {
                        final localizations = AppLocalizations.of(context)!;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => Scaffold(
                              backgroundColor: AppColors.profilePageBackground,
                              body: SafeArea(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 统一顶栏
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 14, 20, 8),
                                      child: Row(
                                        children: [
                                          GlassBackButton(
                                            onTap: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            localizations.personalInfo,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Fredoka',
                                              color: Color(0xFF5A3A15),
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(child: ProfileTab()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarStatusButton(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final stars = authController.currentUser?.totalStars ?? 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFFFCB45).withOpacity(0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD65A).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 星星图标（脉冲动画）
            const AnimatedSvgWidget(
              assetPath: 'assets/images/hi_kiki_star_icon.svg',
              width: 26,
              height: 26,
              animate: false,
              animationType: SvgAnimationType.none,
            ),
            const SizedBox(width: 5),
            // 数字：金色，与星星呼应
            Text(
              '$stars',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD48A00), // 琥珀金，与星星颜色呼应
                fontFamily: 'Fredoka',
                height: 1,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建圆角矢量按钮，使用 Stack 叠加透明 InkWell 捕捉原生的点击事件
  Widget _buildSvgButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          AnimatedSvgWidget(
            assetPath: assetPath,
            width: 48,
            height: 48,
            animate: false,
            animationType: SvgAnimationType.none,
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
