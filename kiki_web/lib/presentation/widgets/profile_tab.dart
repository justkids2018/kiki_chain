import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../controllers/auth_controller.dart';

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
      color: Color(0xFFF8FAFC),
      child: SafeArea(
        child: Obx(() {
          if (authController.isLoggedIn) {
            return _buildLoggedInView(authController);
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
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: Color(0xFF6B7280),
                  ),
                ),

                SizedBox(height: 24),

                // 欢迎文字
                Text(
                  localizations.hiPleaseLogin,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF27273F),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  localizations.loginToViewRecords,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
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

                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建已登录状态视图
  Widget _buildLoggedInView(AuthController authController) {
    final user = authController.currentUser;
    final phone = user?.phone ?? '';
    final maskedPhone = phone.length == 11
        ? '${phone.substring(0, 3)}****${phone.substring(7)}'
        : phone;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息卡片
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00C37D), Color(0xFF3FD280)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user?.nickname.isNotEmpty == true)
                          ? user!.nickname[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // 用户信息
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nickname ?? localizations.defaultUser,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF27273F),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${localizations.phoneLabel}$maskedPhone',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 功能菜单
          Builder(
            builder: (context) => Column(
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.history_rounded,
                  title: AppLocalizations.of(context)!.learningRecords,
                  onTap: () {
                    // TODO: 导航到学习记录页面
                  },
                ),

                SizedBox(height: 12),

                _buildMenuItem(
                  context: context,
                  icon: Icons.star_outline_rounded,
                  title: AppLocalizations.of(context)!.myFavorites,
                  onTap: () {
                    // TODO: 导航到我的收藏页面
                  },
                ),

                SizedBox(height: 12),

                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: AppLocalizations.of(context)!.settings,
                  onTap: () {
                    // TODO: 导航到设置页面
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 退出登录按钮
          _buildLogoutButton(authController),
        ],
      ),
    );
  }

  /// 构建功能菜单项
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Color(0xFF00C37D),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF27273F),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF6B7280),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Color(0xFFEF4444),
                ),
                SizedBox(width: 8),
                Text(
                  localizations.logOut,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          localizations.logOut,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27273F),
          ),
        ),
        content: Text(
          localizations.confirmLogoutMessage,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              localizations.exit,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮（登录/注册）
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: 120,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Color(0xFF00C37D) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Color(0xFF00C37D),
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide(
            color: isPrimary ? Colors.transparent : Color(0xFF00C37D),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
