import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/profile_tab.dart';
import '../widgets/animated_svg/animated_svg.dart';
import '../controllers/auth_controller.dart';
import 'interactive_image_home/interactive_image_home_page.dart';

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
            left: media.padding.left - 5, // 抵消 SVG 内部左侧 15dp 空白，使 LOGO 视觉边缘距离屏幕左边刚好 10dp
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
                  animate: true, // 主 LOGO 启用动画，通过 RepaintBoundary 隔离重绘
                ),
                // 右侧按钮组（保持垂直居中对齐）
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStarStatusButton(context),
                    const SizedBox(width: 12),
                    _buildSvgButton(
                      assetPath: 'assets/images/hi_kiki_learning_record_button.svg',
                      onTap: () {
                        Get.snackbar('提示', '学习记录功能开发中');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildSvgButton(
                      assetPath: 'assets/images/hi_kiki_profile_button.svg',
                      onTap: () {
                        final localizations = AppLocalizations.of(context)!;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: Text(localizations.personalInfo),
                                backgroundColor: AppColors.backgroundCream,
                                foregroundColor: AppColors.textDarkBrown,
                                elevation: 0,
                              ),
                              backgroundColor: AppColors.profilePageBackground,
                              body: const ProfileTab(),
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

  /// 星星状态展示按钮（去掉了背景，icon 尺寸调为 40x40，数字采用 Fredoka 艺术字体）
  Widget _buildStarStatusButton(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AnimatedSvgWidget(
          assetPath: 'assets/images/hi_kiki_star_icon.svg',
          width: 40,
          height: 40,
          animate: false, // 静态展示，避免 WebView 内存和重绘开销
        ),
        const SizedBox(width: 6),
        Obx(() {
          final stars = authController.currentUser?.totalStars ?? 0;
          return Text(
            '$stars',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: KikiUiColors.textPrimary,
              fontFamily: 'Fredoka',
            ),
          );
        }),
      ],
    );
  }

  /// 构建圆角矢量按钮，使用 Stack 叠加透明 InkWell 捕捉原生的点击事件
  Widget _buildSvgButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          AnimatedSvgWidget(
            assetPath: assetPath,
            width: 40,
            height: 40,
            animate: false, // 静态按钮，避免 WebView 内存和重绘开销
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
