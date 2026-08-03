import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/exceptions/app_exceptions.dart';

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
              _infoTile(
                localizations.nickname,
                displayOrNone(user?.nickname),
                onTap: user == null
                    ? null
                    : () => _editNickname(context, auth, user.nickname),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB5A99E),
                ),
              ),
              _infoTile(localizations.phoneNumber, displayOrNone(user?.phone)),
              _infoTile(
                localizations.registeredAt,
                dateOrNone(user?.createdAt),
              ),
              _infoTile(localizations.lastLogin, dateOrNone(user?.lastLoginAt)),
              const SizedBox(height: 12),
              Text(
                '点击昵称即可修改',
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

  Future<void> _editNickname(
    BuildContext context,
    AuthController auth,
    String currentNickname,
  ) async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (_) => _NicknameDialog(initialNickname: currentNickname),
    );
    if (nickname == null || nickname.isEmpty) return;

    try {
      final updated = await auth.updateNickname(nickname);
      if (updated != null && context.mounted) {
        Get.snackbar('修改成功', '昵称已更新', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiResponseException ? e.message : '请稍后重试';
        Get.snackbar('修改失败', message, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _infoTile(
    String label,
    String value, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final tile = Container(
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
          if (trailing != null) trailing,
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: tile,
    );
  }
}

class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({required this.initialNickname});

  final String initialNickname;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '修改昵称',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A342B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 20,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A342B),
                ),
                decoration: InputDecoration(
                  hintText: '请输入昵称',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8F5F0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7BB83F),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogActionButton(
                      label: '取消',
                      backgroundColor: const Color(0xFFF0F2F6),
                      foregroundColor: const Color(0xFF6B6B6B),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogActionButton(
                      label: '确认',
                      backgroundColor: const Color(0xFF7BB83F),
                      foregroundColor: Colors.white,
                      onPressed: () {
                        final value = _controller.text.trim();
                        if (value.isNotEmpty) Navigator.pop(context, value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
