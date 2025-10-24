import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../config/app_color.dart';
import '../widgets/custom_button.dart';
import '../widgets/glassmorphism_slogan.dart';

/// Welcome Page
///
/// App startup page, provides login and register entry
/// If user is already logged in, automatically redirect to home page
///
/// Created: August 9, 2025
/// Last Modified: August 9, 2025
/// Apple style welcome page
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final sloganStyle = TextStyle(
      fontSize: 18,
      color: Colors.black.withOpacity(0.75),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 148, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 148, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black12,
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO
                const SizedBox(height: 12),
                // Title
                GlassmorphismSlogan(
                  slogan: 'Kiki World',
                  style: sloganStyle.copyWith(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 32),
                // Glass morphism Slogan
                // GlassmorphismSlogan(
                  // slogan: 'More than just a machine.',
                  // style: sloganStyle.copyWith(
                      // fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 40),
                // Button group
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: localizations.register,
                      height: 44,
                      width: 120,
                      borderRadius: 20,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      backgroundColor:  AppColors.buttonColorBg,
                      textColor: Colors.white,
                      onPressed: () => Get.toNamed('/register'),
                    ),
                    const SizedBox(width: 24),
                    CustomButton(
                      text: localizations.login,
                      height: 44,
                      width: 120,
                      borderRadius: 20,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      backgroundColor: Colors.white,
                      textColor: AppColors.buttonColorBg,
                      borderColor: AppColors.buttonColorBg,
                      borderWidth: 2,
                      onPressed: () => Get.toNamed('/login'),
// onPressed: () => Get.toNamed(AppConstants.routeChatDify),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
