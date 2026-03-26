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
              const Spacer(flex: 6),
              _buildLoginButton(localizations),
              const SizedBox(height: 14),
              _buildRegisterButton(localizations),
              const SizedBox(height: 24),
              _buildGuestEntry(localizations),
              SizedBox(height: isCompact ? 36.0 : 48.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(bool isCompact) {
    final logoSize = isCompact ? 64.0 : 80.0;
    final iconSize = isCompact ? 32.0 : 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C37D), Color(0xFF3FD280)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isCompact ? 16.0 : 20.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C37D).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.school_rounded, size: iconSize, color: Colors.white),
        ),
        SizedBox(height: isCompact ? 28.0 : 36.0),
        Text(
          'Hi Kiki',
          style: TextStyle(
            fontSize: isCompact ? 42.0 : 52.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27273F),
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '用中文场景，学真实英语',
          style: TextStyle(
            fontSize: isCompact ? 16.0 : 18.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
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

  Widget _buildGuestEntry(AppLocalizations localizations) {
    final authController = Get.find<AuthController>();
    return GestureDetector(
      onTap: authController.enterGuestMode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline_rounded,
              color: Color(0xFF9CA3AF), size: 16),
          const SizedBox(width: 6),
          Text(
            localizations.continueAsGuest,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
