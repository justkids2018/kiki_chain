import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';

/// 未登录状态的Profile界面 - Hi Kiki 风格
class GuestProfile extends StatelessWidget {
  const GuestProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 装饰性图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 60,
                      color: AppColors.primaryGreen,
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Icon(
                        Icons.eco,
                        size: 24,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 欢迎文字
              Text(
                'Hi，快来登录吧',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '登录后可以查看学习记录和收藏',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),

              const SizedBox(height: 40),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    elevation: 2,
                    shadowColor: AppColors.shadowMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 注册按钮
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen, width: 2),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    '注册新账号',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 底部装饰
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass, color: AppColors.darkGreen.withOpacity(0.3), size: 30),
                  const SizedBox(width: 16),
                  Icon(Icons.local_florist, color: AppColors.primaryGreen.withOpacity(0.3), size: 24),
                  const SizedBox(width: 16),
                  Icon(Icons.filter_vintage, color: AppColors.orange.withOpacity(0.3), size: 28),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
