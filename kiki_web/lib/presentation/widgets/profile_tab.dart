import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'app_gradient_button.dart';
import '../controllers/auth_controller.dart';
import '../pages/profile_feature/about_page.dart';
import '../pages/profile_feature/help_feedback_page.dart';
import '../pages/profile_feature/my_info_page.dart';

/// Profile Tab（我的页面）
///
/// 根据登录状态显示不同内容：
/// - 未登录：默认头像 + 登录/注册按钮
/// - 已登录：用户信息 + 功能菜单 + 退出登录
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Container(
      color: AppColors.profilePageBackground,
      child: SafeArea(
        child: Obx(() {
          if (authController.isLoggedIn) {
            return _buildLoggedInView(context, authController);
          } else {
            return _buildGuestView();
          }
        }),
      ),
    );
  }

  /// 构建未登录状态视图
  Widget _buildGuestView() {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),

                // 默认头像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFDDE8B9), width: 2),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: const Color(0xFF7CB342),
                  ),
                ),

                SizedBox(height: 24),

                // 欢迎文字
                Text(
                  localizations.hiPleaseLogin,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E342E),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  localizations.loginToViewRecords,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),

                SizedBox(height: 32),

                // 登录/注册按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      text: localizations.login,
                      onPressed: () => Get.toNamed('/login'),
                      isPrimary: true,
                    ),
                    SizedBox(width: 16),
                    _buildActionButton(
                      text: localizations.register,
                      onPressed: () => Get.toNamed('/register'),
                      isPrimary: false,
                    ),
                  ],
                ),

                SizedBox(height: 14),

                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建已登录状态视图
  Widget _buildLoggedInView(
      BuildContext context, AuthController authController) {
    final localizations = AppLocalizations.of(context)!;
    final user = authController.currentUser;
    final phone = user?.phone ?? '';
    final maskedPhone = phone.length == 11
        ? '${phone.substring(0, 3)}****${phone.substring(7)}'
        : phone;
    final displayName = (user?.nickname.trim().isNotEmpty == true)
        ? user!.nickname.trim()
        : localizations.noneValue;
    final displayId = (user?.id.trim().isNotEmpty == true)
        ? user!.id.trim()
        : (maskedPhone.isNotEmpty ? maskedPhone : localizations.noneValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.profileHeaderCardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.profileCardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6E7AA),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (user?.nickname.isNotEmpty == true)
                          ? user!.nickname[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7CB342),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 用户信息
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E2A27),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Color(0xFF9B8F84),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${localizations.userId}: $displayId',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9B8F84),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildVipStatus(authController),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _buildMenuCard(
            items: [
              _ProfileMenuData(
                icon: Icons.person,
                color: const Color(0xFF7CB342),
                title: localizations.myInfo,
                onTap: () => Get.to(() => const MyInfoPage()),
              ),
              _ProfileMenuData(
                icon: Icons.shield,
                color: const Color(0xFFF6B722),
                title: localizations.accountAndSecurity,
                onTap: () {
                  Get.snackbar(localizations.hint, localizations.settingsInDev);
                },
              ),
              _ProfileMenuData(
                icon: Icons.notifications,
                color: const Color(0xFF5DB2FF),
                title: localizations.messageNotifications,
                onTap: () {
                  Get.snackbar(localizations.hint, localizations.settingsInDev);
                },
              ),
              _ProfileMenuData(
                icon: Icons.help,
                color: const Color(0xFF9C6ADE),
                title: localizations.helpAndFeedback,
                onTap: () => Get.to(() => const HelpFeedbackPage()),
              ),
              _ProfileMenuData(
                icon: Icons.favorite,
                color: const Color(0xFFFF6F9C),
                title: localizations.about,
                onTap: () => Get.to(() => const AboutPage()),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 退出登录按钮
          _buildLogoutButton(authController),
        ],
      ),
    );
  }

  Widget _buildVipStatus(AuthController authController) {
    final isVip = authController.isVipActive;

    if (!isVip) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 32,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppConstants.routeSubscription),
            icon: const Icon(Icons.workspace_premium_rounded, size: 15),
            label: const Text('充值'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: const Color(0xFF4B2800),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2C7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFFC857),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 15,
              color: Color(0xFF9A5A00),
            ),
            SizedBox(width: 5),
            Text(
              'VIP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6F3F00),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建退出登录按钮
  Widget _buildLogoutButton(AuthController authController) {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return GestureDetector(
          onTap: () => _showLogoutDialog(authController),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE7DFD4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: const Color(0xFFEF6C63),
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.logOut,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF6C63),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(AuthController authController) {
    final context = Get.context!;
    final localizations = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        backgroundColor: KikiUiColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          localizations.confirmExit,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: KikiUiColors.textPrimary,
          ),
        ),
        content: Text(
          localizations.confirmLogoutMessage,
          style: const TextStyle(
            fontSize: 15,
            color: KikiUiColors.textSecondary,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        actions: [
          SizedBox(
            width: 118,
            child: AppGradientButton(
              text: localizations.cancel,
              onPressed: () => Get.back(),
              height: 44,
              borderRadius: 14,
              fontSize: 15,
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF5D9), Color(0xFFD9EFB8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              textColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 118,
            child: AppGradientButton(
              text: localizations.logOut,
              onPressed: () {
                Get.back();
                authController.logout();
              },
              height: 44,
              borderRadius: 14,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return SizedBox(
        width: 120,
        child: AppGradientButton(
          text: text,
          onPressed: onPressed,
          height: 48,
          borderRadius: 12,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SizedBox(
      width: 120,
      child: AppGradientButton(
        text: text,
        onPressed: onPressed,
        height: 48,
        borderRadius: 12,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5D9), Color(0xFFD9EFB8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        textColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildMenuCard({required List<_ProfileMenuData> items}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.profileCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildNewProfileMenuRow(items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildNewProfileMenuRow(_ProfileMenuData item) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E2A27),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFFB9B1AA), size: 26),
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      dense: false,
    );
  }
}

class _ProfileMenuData {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuData({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });
}
