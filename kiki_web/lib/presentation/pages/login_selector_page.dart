import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_gradient_button.dart';

/// 登录选择页（独立页面）
/// 仅负责“立即登录/立即注册”入口分发。
class LoginSelectorPage extends StatelessWidget {
  const LoginSelectorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 430;

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 700 ? 22 : 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAppIcon(),
                      SizedBox(height: isCompactHeight ? 70 : 76),
                      AppGradientButton(
                        text: localizations.loginNow,
                        onPressed: () => Get.toNamed('/login'),
                        height: 52,
                        borderRadius: 28,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: isCompactHeight ? 8 : 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.noAccountYet,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.offNamed('/register'),
                            child: Text(
                              localizations.register,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryGreen,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/icon/app_icon.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
