import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/user.dart';
import '../../../../theme/app_colors.dart';
import '../../../controllers/auth_controller.dart';

/// 已登录状态的Profile界面 - Hi Kiki 风格
class LoggedInProfile extends StatelessWidget {
  final User user;

  const LoggedInProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(),

          const SizedBox(height: 24),

          // 统计卡片
          _buildStatsCards(),

          const SizedBox(height: 24),

          // 菜单列表
          _buildMenuList(authController),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: user.avatar != null ? null : AppColors.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 3,
              ),
              image: user.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(user.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.avatar == null
                ? Icon(Icons.person, size: 36, color: AppColors.primaryGreen)
                : null,
          ),

          const SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.nickname,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkBrown,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.eco,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '手机号：${_maskPhone(user.phone)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),

          // 编辑按钮
          IconButton(
            onPressed: () {
              Get.snackbar('提示', '编辑资料功能开发中');
            },
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_stories,
            label: '学习天数',
            value: '0',
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            label: '收藏',
            value: '0',
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            label: '成就',
            value: '0',
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(AuthController authController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.bar_chart_rounded,
            title: '学习记录',
            iconColor: AppColors.blue,
            onTap: () {
              Get.snackbar('提示', '学习记录功能开发中');
            },
          ),
          Divider(height: 1, color: AppColors.borderLight),
          _buildMenuItem(
            icon: Icons.star_outline_rounded,
            title: '我的收藏',
            iconColor: AppColors.orange,
            onTap: () {
              Get.snackbar('提示', '收藏功能开发中');
            },
          ),
          Divider(height: 1, color: AppColors.borderLight),
          _buildMenuItem(
            icon: Icons.emoji_events_outlined,
            title: '我的成就',
            iconColor: AppColors.purple,
            onTap: () {
              Get.snackbar('提示', '成就功能开发中');
            },
          ),
          Divider(height: 1, color: AppColors.borderLight),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: '设置',
            iconColor: AppColors.textGray,
            onTap: () {
              Get.snackbar('提示', '设置功能开发中');
            },
          ),
          Divider(height: 1, color: AppColors.borderLight),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: '退出登录',
            iconColor: AppColors.red,
            textColor: AppColors.red,
            showArrow: false,
            onTap: () async {
              final shouldLogout = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    '退出登录',
                    style: TextStyle(
                      color: AppColors.textDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    '确定要退出登录吗？',
                    style: TextStyle(color: AppColors.textBrown),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        '取消',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('退出'),
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
    Color? iconColor,
    Color? textColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryGreen).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.textDarkBrown,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.textLightGray,
                size: 24,
              ),
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
