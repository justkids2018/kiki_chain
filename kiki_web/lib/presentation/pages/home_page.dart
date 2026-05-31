import 'package:flutter/material.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/profile_tab.dart';
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
            top: media.padding.top + 12,
            right: 20,
            child: _buildProfileEntryButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileEntryButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
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
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: KikiUiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
