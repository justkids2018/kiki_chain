import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class RegisterPageController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  GlobalKey<FormState> get formKey => _auth.registerFormKey;

  TextEditingController get phoneController => _auth.registerPhoneController;
  TextEditingController get passwordController =>
      _auth.registerPasswordController;
  TextEditingController get confirmPasswordController =>
      _auth.registerConfirmPasswordController;

  bool get passwordVisible => _auth.registerPasswordVisible;
  bool get confirmPasswordVisible => _auth.registerConfirmPasswordVisible;
  bool get agreeToTerms => _auth.agreeToTerms;

  String? Function(String?) get validatePhone => _auth.validatePhone;
  String? Function(String?) get validatePassword => _auth.validatePassword;
  String? Function(String?) get validateConfirmPassword =>
      _auth.validateConfirmPassword;

  void togglePasswordVisibility() {
    _auth.toggleRegisterPasswordVisibility();
  }

  void toggleConfirmPasswordVisibility() {
    _auth.toggleRegisterConfirmPasswordVisibility();
  }

  void setAgreeToTerms(bool value) {
    _auth.setAgreeToTerms(value);
  }

  Future<bool> register() {
    return _auth.register();
  }
}
