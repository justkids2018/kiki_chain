import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// 我的页面Tab
class ProfileTab extends GetView<HomeController> {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(),
          
          // 功能列表
          _buildFeatureList(),
        ],
      ),
    );
  }
  
  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Obx(() {
        final user = controller.currentUser.value;
        
        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '未登录',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '点击登录',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
          ],
        );
      }),
    );
  }
  
  /// 构建功能列表
  Widget _buildFeatureList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.analytics,
            title: '学习统计',
            subtitle: '查看学习进度和成就',
            onTap: () {
              Get.snackbar('功能提示', '学习统计功能正在开发中');
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.bookmark,
            title: '收藏夹',
            subtitle: '管理收藏的生词',
            onTap: () {
              Get.snackbar('功能提示', '收藏夹功能正在开发中');
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.history,
            title: '学习历史',
            subtitle: '查看学习记录',
            onTap: () {
              Get.snackbar('功能提示', '学习历史功能正在开发中');
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.settings,
            title: '设置',
            subtitle: '个人偏好设置',
            onTap: () {
              _showSettingsDialog();
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.help,
            title: '帮助与反馈',
            subtitle: '获取帮助或提供反馈',
            onTap: () {
              Get.snackbar('功能提示', '帮助功能正在开发中');
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.info,
            title: '关于',
            subtitle: '版本信息',
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.logout,
            title: '退出登录',
            subtitle: '安全退出应用',
            onTap: () {
              _showLogoutDialog();
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
  
  /// 构建功能项
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? const Color(0xFF4CAF50),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textColor?.withOpacity(0.7) ?? Colors.grey,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
  
  /// 构建分隔线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }
  
  /// 显示设置对话框
  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('深色模式'),
              trailing: Switch(
                value: false,
                onChanged: null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('推送通知'),
              trailing: Switch(
                value: true,
                onChanged: null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 显示关于对话框
  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('关于'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Color(0xFF4CAF50),
            ),
            SizedBox(height: 16),
            Text(
              '扎根理论',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('版本 1.0.0'),
            SizedBox(height: 16),
            Text(
              '一个简单易用的生词学习应用，帮助你轻松掌握新词汇。',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 显示登出对话框
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.logout();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
