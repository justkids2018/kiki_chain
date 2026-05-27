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
          Text(
            '个人中心',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E2A27),
            ),
          ),

          SizedBox(height: 18),

          // 用户信息卡片
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8DFC6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD9E7A9),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (user?.nickname.isNotEmpty == true)
                          ? user!.nickname[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7CB342),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

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
                                  user?.nickname ?? 'Kiki 小朋友',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E2A27),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF9B8F84),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID: ${user?.id ?? maskedPhone}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF9B8F84),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildLevelBadge(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildMenuCard(
            items: const [
              _ProfileMenuData(
                  icon: Icons.person, color: Color(0xFF7CB342), title: '我的信息'),
              _ProfileMenuData(
                  icon: Icons.shield, color: Color(0xFFF6B722), title: '账号与安全'),
              _ProfileMenuData(
                  icon: Icons.notifications,
                  color: Color(0xFF5DB2FF),
                  title: '消息通知'),
              _ProfileMenuData(
                  icon: Icons.help, color: Color(0xFF9C6ADE), title: '帮助与反馈'),
              _ProfileMenuData(
                  icon: Icons.favorite,
                  color: Color(0xFFFF6F9C),
                  title: '关于我们'),
            ],
          ),

          SizedBox(height: 24),

          // 退出登录按钮
          _buildLogoutButton(authController),
        ],
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
          localizations.confirmExit,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27273F),
          ),
        ),
        content: Text(
          localizations.confirmLogoutMessage,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          _buildActionButton(
            text: localizations.cancel,
            onPressed: () => Get.back(),
            isPrimary: false,
          ),
          SizedBox(width: 12),
          _buildActionButton(
            text: localizations.logOut,
            onPressed: () {
              Get.back();
              authController.logout();
            },
            isPrimary: true,
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

  Widget _buildLevelBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2C7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
              SizedBox(width: 4),
              Text(
                'Lv.3',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB88900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 10,
              backgroundColor: const Color(0xFFECECEC),
              color: const Color(0xFF8BC34A),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '60/100',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8D847C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({required List<_ProfileMenuData> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E3DB), width: 1),
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
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E2A27),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFFB9B1AA), size: 30),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      dense: false,
    );
  }
}

class _ProfileMenuData {
  final IconData icon;
  final Color color;
  final String title;

  const _ProfileMenuData({
    required this.icon,
    required this.color,
    required this.title,
  });
}
