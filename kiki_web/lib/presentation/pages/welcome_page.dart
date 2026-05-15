import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../config/app_color.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

/// Welcome Page — Mobile-first fixed layout (no scroll)
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();
    while (!authController.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (authController.isLoggedIn || authController.isGuestMode) {
      Get.offAllNamed(AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 28.0 : 64.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 5),
              _buildBranding(isCompact),
              const Spacer(flex: 8),
              _buildLoginButton(localizations),
              const SizedBox(height: 14),
              _buildRegisterButton(localizations),
              SizedBox(height: isCompact ? 36.0 : 48.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(bool isCompact) {
    final logoSize = isCompact ? 64.0 : 80.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isCompact ? 16.0 : 20.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C37D).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/icon/app_icon.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: isCompact ? 28.0 : 36.0),
        Text(
          'Hi Kiki',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 42.0 : 52.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27273F),
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLoginButton(AppLocalizations localizations) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColorBg,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          localizations.login,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AppLocalizations localizations) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () => Get.toNamed('/register'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonColorBg,
          side: BorderSide(color: AppColors.buttonColorBg, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          localizations.register,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

}
