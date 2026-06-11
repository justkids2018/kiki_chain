import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/profile_tab.dart';
import '../widgets/animated_svg/animated_svg.dart';
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
            top: media.padding.top + 27, // Increased by 15dp (from 12 to 27)
            right: 20,
            child: Row(
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
          ),
        ],
      ),
    );
  }

  /// 星星状态展示按钮
  Widget _buildStarStatusButton(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSvgWidget(
            assetPath: 'assets/images/hi_kiki_star_icon.svg',
            width: 20,
            height: 20,
          ),
          SizedBox(width: 4),
          Text(
            '0',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: KikiUiColors.textPrimary,
            ),
          ),
        ],
      ),
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
