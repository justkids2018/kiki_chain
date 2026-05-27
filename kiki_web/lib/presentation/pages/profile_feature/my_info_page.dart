import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的信息'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoTile('用户ID', user?.id ?? '-'),
          _infoTile('昵称',
              (user?.nickname.isNotEmpty ?? false) ? user!.nickname : '-'),
          _infoTile('手机号', user?.phone ?? '-'),
          _infoTile('注册时间', user?.createdAt.toLocal().toString() ?? '-'),
          _infoTile('最近登录', user?.lastLoginAt.toLocal().toString() ?? '-'),
          const SizedBox(height: 12),
          const Text(
            '说明：当前版本仅支持查看信息，编辑能力后续开放。',
            style: TextStyle(color: Color(0xFF7A6A5B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6DED2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8D847C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E2A27),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
