import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../../../design_ui/kiki_ui_kit.dart';
import '../controllers/register_page_controller.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegisterPageController controller =
        Get.find<RegisterPageController>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: KikiUiDecor.pageBackgroundDecor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardVisible =
                  MediaQuery.of(context).viewInsets.bottom > 0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: keyboardVisible ? 0 : constraints.maxHeight - 38,
                  ),
                  child: Align(
                    alignment: keyboardVisible
                        ? Alignment.topCenter
                        : Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.createAccount,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: KikiUiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RegisterForm(controller: controller),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localizations.alreadyHaveAccount,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KikiUiColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Get.offNamed('/login'),
                                child: Text(
                                  localizations.login,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: KikiUiColors.brandGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
