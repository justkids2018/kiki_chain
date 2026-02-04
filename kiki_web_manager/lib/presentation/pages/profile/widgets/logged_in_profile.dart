import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/user.dart';
import '../../../controllers/auth_controller.dart';

/// 已登录状态的Profile界面
class LoggedInProfile extends StatelessWidget {
  final User user;

  const LoggedInProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(),

          SizedBox(height: 24),

          // 菜单列表
          _buildMenuList(authController),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: user.avatar != null ? null : Color(0xFFE2E8F0),
              shape: BoxShape.circle,
              image: user.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(user.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.avatar == null
                ? Icon(Icons.person, size: 32, color: Color(0xFF6B7280))
                : null,
          ),

          SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF27273F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '手机号：${_maskPhone(user.phone)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(AuthController authController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.bar_chart_rounded,
            title: '学习记录',
            onTap: () {
              // TODO: 导航到学习记录页
              Get.snackbar('提示', '学习记录功能开发中');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.star_outline_rounded,
            title: '我的收藏',
            onTap: () {
              // TODO: 导航到收藏页
              Get.snackbar('提示', '收藏功能开发中');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: '设置',
            onTap: () {
              // TODO: 导航到设置页
              Get.snackbar('提示', '设置功能开发中');
            },
          ),
          Divider(height: 1),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: '退出登录',
            textColor: Color(0xFFEF4444),
            showArrow: false,
            onTap: () async {
              // 确认弹窗
              final shouldLogout = await Get.dialog<bool>(
                AlertDialog(
                  title: Text('退出登录'),
                  content: Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                      ),
                      child: Text('退出'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authController.logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Color(0xFF27273F), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Color(0xFF27273F),
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 24),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }
}
