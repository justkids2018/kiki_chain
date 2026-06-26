import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/auth_controller.dart';

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    String displayOrNone(String? value) {
      final text = value?.trim() ?? '';
      return text.isEmpty ? localizations.noneValue : text;
    }

    String dateOrNone(DateTime? value) {
      return value == null
          ? localizations.noneValue
          : value.toLocal().toString();
    }

    return Obx(
      () {
        final user = auth.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.myInfo),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoTile(localizations.userId, displayOrNone(user?.id)),
              _infoTile(localizations.nickname, displayOrNone(user?.nickname)),
              _infoTile(localizations.phoneNumber, displayOrNone(user?.phone)),
              _infoTile(
                localizations.registeredAt,
                dateOrNone(user?.createdAt),
              ),
              _infoTile(localizations.lastLogin, dateOrNone(user?.lastLoginAt)),
              const SizedBox(height: 12),
              Text(
                localizations.profileReadonlyHint,
                style: const TextStyle(
                  color: Color(0xFF7A6A5B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
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
