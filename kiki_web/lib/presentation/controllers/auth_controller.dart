import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../../core/services/app_services.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/request_manager.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/di/service_locator.dart';
import '../../utils/crypto_utils.dart';

/// 认证控制器
///
/// 负责处理登录、注册相关的业务逻辑
/// 使用GetX状态管理，提供响应式的用户状态
///
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年8月9日
class AuthController extends GetxController {
  final IAuthRepository _authRepository;

  AuthController({IAuthRepository? authRepository})
      : _authRepository =
            authRepository ?? ServiceLocator.instance.authRepository;

  // 响应式状态
  final _currentUser = Rxn<User>();
  final _isLoggedIn = false.obs;
  final _isInitialized = false.obs;

  // 表单控制器
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // 登录表单字段
  final loginIdentifierController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // 注册表单字段
  final registerPhoneController = TextEditingController();
  final registerNicknameController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();

  // 密码可见性控制
  final _loginPasswordVisible = false.obs;
  final _registerPasswordVisible = false.obs;
  final _registerConfirmPasswordVisible = false.obs;

  // 用户协议同意状态
  final _agreeToTerms = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isInitialized => _isInitialized.value;
  bool get loginPasswordVisible => _loginPasswordVisible.value;
  bool get registerPasswordVisible => _registerPasswordVisible.value;
  bool get registerConfirmPasswordVisible =>
      _registerConfirmPasswordVisible.value;
  bool get agreeToTerms => _agreeToTerms.value;

  // Helper to get localizations
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();

    // 测试默认手机号和密码
    loginIdentifierController.text = '13800138003';
    loginPasswordController.text = 'password123';

    // 注册表单测试数据
    registerPhoneController.text = '';
    registerNicknameController.text = '';
    registerPasswordController.text = '';
    registerConfirmPasswordController.text = '';
  }

  @override
  void onClose() {
    // 清理控制器
    loginIdentifierController.dispose();
    loginPasswordController.dispose();
    registerPhoneController.dispose();
    registerNicknameController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }

  void _initializeAuthState() {
    _isInitialized.value = false;
    _checkLoginStatus().whenComplete(() {
      _isInitialized.value = true;
    });
  }

  /// 检查登录状态
  ///
  /// 应用启动时检查是否已登录
  Future<void> _checkLoginStatus() async {
    try {
      final token = await AppServices.instance.localStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        RequestManager.instance.setAuthToken(token);
        final userInfo = AppServices.instance.localStorage.getUserInfo();
        if (userInfo != null) {
          _currentUser.value = User.fromJson(userInfo);
          _isLoggedIn.value = true;
          AppLogger.info(
              'User already logged in: ${_currentUser.value?.nickname}');
        }
      } else {
        RequestManager.instance.clearAuthToken();
      }
    } catch (e) {
      AppLogger.error('Check login status failed', e);
    }
  }

  /// 用户登录
  ///
  /// 参数:
  /// - [identifier] 登录标识符（用户名或邮箱）
  /// - [password] 密码
  ///
  /// 返回:
  /// - [bool] 登录是否成功
  Future<bool> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return false;
    }

    try {
      EasyLoading.show(status: _l10n.loggingIn);

      final identifier = loginIdentifierController.text.trim();
      final password = loginPasswordController.text;

      final user = await _authRepository.login(identifier, password);
      if (user == null) {
        EasyLoading.showError(_l10n.loginFailed);
        AppLogger.error('Login failed: repository returned null user');
        return false;
      }

      _currentUser.value = user;
      _isLoggedIn.value = true;

      await EasyLoading.showSuccess(_l10n.loginSuccess);
      AppLogger.info('Login successful for user: ${user.nickname}');

      // 清空表单
      _clearLoginForm();

      // 导航到首页
      await _replaceRouteSafely('/home');
      return true;
    } on ApiResponseException catch (e) {
      // 处理所有异常（API响应、网络错误、认证错误等）
      String errorMessage = e.message;

      // 特殊处理需要重新认证的情况
      // if (e.needsReauth) {
      // errorMessage = '登录已过期，请重新登录';
      // 可以在这里执行重新认证逻辑
      // }

      EasyLoading.showError(errorMessage);
      AppLogger.error('Login failed: ${e.message}', e);
      return false;
    } catch (e) {
      // 处理其他未知异常
      final errorMessage = _l10n.loginFailed;
      EasyLoading.showError(errorMessage);
      AppLogger.error('Login failed with unknown error', e);
      return false;
    }
  }

  /// 用户注册
  ///
  /// 包含表单验证，确保手机号、密码格式正确
  /// 验证密码和确认密码是否一致
  ///
  /// 返回:
  /// - [bool] 注册是否成功
  Future<bool> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return false;
    }

    try {
      EasyLoading.show(status: _l10n.registering);

      final phone = registerPhoneController.text.trim();
      final password = registerPasswordController.text;
      final nickname = registerNicknameController.text.trim();

      final user = await _authRepository.register(
        phone,
        password,
        nickname: nickname.isEmpty ? null : nickname,
      );

      if (user == null) {
        EasyLoading.showError(_l10n.registerDataEmpty);
        return false;
      }

      _currentUser.value = user;
      _isLoggedIn.value = true;

      await EasyLoading.showSuccess(_l10n.registerSuccess);
      AppLogger.info('Registration successful for user: ${user.nickname}');

      // 清空表单
      _clearRegisterForm();

      // 导航到首页
      await _replaceRouteSafely('/home');
      return true;
    } on ApiResponseException catch (e) {
      // 处理所有异常（API响应、网络错误、认证错误等）
      String errorMessage = e.message;
      if (e.isRetryable) {
        errorMessage += _l10n.pleaseTryAgainLater;
      }
      EasyLoading.showError(errorMessage);
      AppLogger.error('Registration failed: ${e.message}', e);
      return false;
    } catch (e) {
      // 处理其他未知异常
      final errorMessage = _l10n.registerFailed;
      EasyLoading.showError(errorMessage);
      AppLogger.error('Registration failed with unknown error', e);
      return false;
    }
  }

  /// 用户退出登录
  ///
  /// 清除所有本地存储的用户信息和token
  /// 重置用户状态，导航回欢迎页
  Future<void> logout() async {
    try {
      EasyLoading.show(status: _l10n.loggingOut);

      // 清除本地存储
      await AppServices.instance.localStorage.clearUserData();

      // 重置状态
      _currentUser.value = null;
      _isLoggedIn.value = false;

      // 清空表单
      _clearAllForms();

      await EasyLoading.showSuccess(_l10n.loggedOut);
      AppLogger.info('User logged out successfully');

      // 导航到欢迎页
      await _replaceRouteSafely('/welcome');
    } catch (e) {
      EasyLoading.showError(_l10n.logoutFailed);
      AppLogger.error('Logout failed', e);
    }
  }

  /// 更新本地缓存的用户总星星数
  Future<void> updateUserStars(int totalStars) async {
    final user = _currentUser.value;
    if (user != null) {
      final updatedUser = user.copyWith(totalStars: totalStars);
      _currentUser.value = updatedUser;
      await AppServices.instance.localStorage.setUserInfo(updatedUser.toJson());
      AppLogger.info('AuthController: 更新本地用户总星星数为 $totalStars 颗星');
    }
  }

  /// 切换登录密码可见性
  void toggleLoginPasswordVisibility() {
    _loginPasswordVisible.value = !_loginPasswordVisible.value;
  }

  /// 切换注册密码可见性
  void toggleRegisterPasswordVisibility() {
    _registerPasswordVisible.value = !_registerPasswordVisible.value;
  }

  /// 切换确认密码可见性
  void toggleRegisterConfirmPasswordVisibility() {
    _registerConfirmPasswordVisible.value =
        !_registerConfirmPasswordVisible.value;
  }

  /// 设置用户协议同意状态
  void setAgreeToTerms(bool value) {
    _agreeToTerms.value = value;
  }

  /// 验证登录手机号
  ///
  /// 参数:
  /// - [value] 输入的手机号
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateLoginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.pleaseEnterPhone;
    }

    value = value.trim();

    // 验证中国大陆手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return _l10n.pleaseEnterValidPhone;
    }

    return null;
  }

  /// 验证密码
  ///
  /// 参数:
  /// - [value] 输入的密码
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _l10n.pleaseEnterPassword;
    }

    // 检查密码长度（6-20位）
    if (value.length < 6 || value.length > 20) {
      return _l10n.passwordLengthError;
    }

    // 检查是否包含字母和数字
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
      return _l10n.passwordFormatError;
    }

    return null;
  }

  /// 验证昵称
  ///
  /// 参数:
  /// - [value] 输入的昵称
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateNickname(String? value) {
    // 昵称是可选的
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    value = value.trim();

    // 检查昵称长度（2-20字符）
    if (value.length < 2 || value.length > 20) {
      return _l10n.nicknameLengthError;
    }

    return null;
  }

  /// 验证注册密码
  ///
  /// 参数:
  /// - [value] 输入的密码
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateRegisterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _l10n.pleaseEnterPassword;
    }

    // 检查密码长度（6-20位）
    if (value.length < 6 || value.length > 20) {
      return _l10n.passwordLengthError;
    }

    // 检查是否包含字母和数字
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
      return _l10n.passwordFormatError;
    }

    return null;
  }

  /// 验证手机号
  ///
  /// 参数:
  /// - [value] 输入的手机号
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l10n.pleaseEnterPhone;
    }

    value = value.trim();

    // 验证中国大陆手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return _l10n.pleaseEnterValidPhone;
    }

    return null;
  }

  /// 验证确认密码
  ///
  /// 参数:
  /// - [value] 输入的确认密码
  ///
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _l10n.pleaseEnterPasswordAgain;
    }

    if (value != registerPasswordController.text) {
      return _l10n.passwordMismatch;
    }

    return null;
  }

  /// 清空登录表单
  void _clearLoginForm() {
    loginIdentifierController.clear();
    loginPasswordController.clear();
    _loginPasswordVisible.value = false;
  }

  /// 清空注册表单
  void _clearRegisterForm() {
    registerPhoneController.clear();
    registerNicknameController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    _registerPasswordVisible.value = false;
    _registerConfirmPasswordVisible.value = false;
  }

  /// 清空所有表单
  void _clearAllForms() {
    _clearLoginForm();
    _clearRegisterForm();
  }

  /// 安全替换路由：先关闭 EasyLoading，再切换页面，避免 Navigator 锁定异常。
  Future<void> _replaceRouteSafely(String route) async {
    if (EasyLoading.isShow) {
      await EasyLoading.dismiss(animation: false);
    }

    await Future<void>.delayed(Duration.zero);

    if (Get.context == null) {
      Get.offAllNamed(route);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.offAllNamed(route);
      }
    });
  }

  /// 进入游客模式
  ///
  /// 生成临时游客ID，允许用户在不登录的情况下使用应用
  /// 游客数据仅存储在本地
  Future<void> enterGuestMode() async {
    try {
      // 生成游客ID
      final guestId = CryptoUtils.generateGuestId();

      // 存储游客标识
      await AppServices.instance.localStorage.setString('guest_id', guestId);
      await AppServices.instance.localStorage.setBool('is_guest_mode', true);

      AppLogger.info('进入游客模式: $guestId');

      // 导航到首页
      await _replaceRouteSafely('/home');
    } catch (e) {
      EasyLoading.showError(_l10n.guestModeFailed);
      AppLogger.error('Enter guest mode failed', e);
    }
  }

  /// 检查是否为游客模式
  bool get isGuestMode {
    try {
      return AppServices.instance.localStorage.getBool('is_guest_mode') ??
          false;
    } catch (e) {
      AppLogger.error('Check guest mode failed', e);
      return false;
    }
  }

  /// 获取游客ID
  String? get guestId {
    try {
      return AppServices.instance.localStorage.getString('guest_id');
    } catch (e) {
      AppLogger.error('Get guest id failed', e);
      return null;
    }
  }
}
