import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 未登录状态的Profile界面
class GuestProfile extends StatelessWidget {
  const GuestProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 默认头像
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: Color(0xFF6B7280),
              ),
            ),

            SizedBox(height: 24),

            // 提示文字
            Text(
              'Hi，快来登录吧',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27273F),
              ),
            ),

            SizedBox(height: 32),

            // 登录按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C37D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 注册按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Get.toNamed('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF00C37D),
                  side: BorderSide(color: Color(0xFF00C37D), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '注册',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
