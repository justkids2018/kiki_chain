import 'package:flutter/material.dart';
import 'package:kikichain/generated/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const InteractiveImageHomePage(),
          Positioned(
            top: media.padding.top + 12,
            right: 20,
            child: _buildProfileEntryButton(context, localizations),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileEntryButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: Text(localizations.profile),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF27273F),
                  elevation: 0,
                ),
                backgroundColor: const Color(0xFFF8FAFC),
                body: const ProfileTab(),
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Color(0xFF4B5563),
              ),
              const SizedBox(width: 6),
              Text(
                localizations.profile,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
