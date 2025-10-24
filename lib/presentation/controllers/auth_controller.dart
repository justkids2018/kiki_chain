import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../domain/entities/user.dart';
import '../../core/services/app_services.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/request_manager.dart';
import '../../core/exceptions/app_exceptions.dart';

/// 认证控制器
/// 
/// 负责处理登录、注册相关的业务逻辑
/// 使用GetX状态管理，提供响应式的用户状态
/// 
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年8月9日
class AuthController extends GetxController {
  // 便捷访问器
  get _authRepository => AppServices.instance.authRepository;
  
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
  final registerUsernameController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerInviteCodeController = TextEditingController();
  
  // 角色选择
  final _selectedRoleId = RxnInt();
  
  // 密码可见性控制
  final _loginPasswordVisible = false.obs;
  final _registerPasswordVisible = false.obs;
  final _registerConfirmPasswordVisible = false.obs;
  
  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isInitialized => _isInitialized.value;
  bool get loginPasswordVisible => _loginPasswordVisible.value;
  bool get registerPasswordVisible => _registerPasswordVisible.value;
  bool get registerConfirmPasswordVisible => _registerConfirmPasswordVisible.value;
  int? get selectedRoleId => _selectedRoleId.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();

  // 测试默认手机号和密码
  loginIdentifierController.text = '';
  loginPasswordController.text = '';

    // 注册表单测试数据
  registerUsernameController.text = '';
  registerPhoneController.text = '';
  registerPasswordController.text = '';
  registerConfirmPasswordController.text = '';
  registerInviteCodeController.text = '';
  }
  
  @override
  void onClose() {
    // 清理控制器
    loginIdentifierController.dispose();
    loginPasswordController.dispose();
  registerUsernameController.dispose();
  registerPhoneController.dispose();
  registerPasswordController.dispose();
  registerConfirmPasswordController.dispose();
  registerInviteCodeController.dispose();
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
          AppLogger.info('User already logged in: ${_currentUser.value?.name}');
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
      EasyLoading.show(status: '登录中...');
      
      final identifier = loginIdentifierController.text.trim();
      final password = loginPasswordController.text;
      
      final user = await _authRepository.login(identifier, password);
      
      _currentUser.value = user;
      _isLoggedIn.value = true;
      
      EasyLoading.showSuccess('登录成功');
      AppLogger.info('Login successful for user: ${user.name}');
      
      // 清空表单
      _clearLoginForm();
      
      // 导航到首页
      Get.offAllNamed('/home');
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
      const errorMessage = '登录失败，请重试';
      EasyLoading.showError(errorMessage);
      AppLogger.error('Login failed with unknown error', e);
      return false;
      
    } finally {
      EasyLoading.dismiss();
    }
  }
  
  /// 验证邀请码格式和有效性
  /// 
  /// 邀请码格式：4位数字，表示当前月份 + 固定01日 (MM01)
  /// 例如：1001 表示10月1日，0701 表示7月1日
  /// 邀请码必须与当前月份匹配
  /// 
  /// 参数:
  /// - [inviteCode] 邀请码字符串
  /// 
  /// 返回:
  /// - [bool] 邀请码是否有效
  bool validateInviteCode(String inviteCode) {
    // 检查格式：必须是4位数字
    if (inviteCode.length != 4) {
      return false;
    }
    
    // 检查是否全为数字
    if (!RegExp(r'^\d{4}$').hasMatch(inviteCode)) {
      return false;
    }
    
    // 解析月份和日期
    final month = int.tryParse(inviteCode.substring(0, 2));
    final day = int.tryParse(inviteCode.substring(2, 4));
    
    // 验证日期必须是01
    if (day != 1) {
      return false;
    }
    
    // 验证月份范围
    if (month == null || month < 1 || month > 12) {
      return false;
    }
    
    // 获取当前月份
    final currentMonth = DateTime.now().month;
    
    // 验证邀请码必须是当前月份
    if (month != currentMonth) {
      return false;
    }
    
    return true;
  }
  
  /// 用户注册
  /// 
  /// 包含表单验证，确保用户名、邮箱、密码格式正确
  /// 验证密码和确认密码是否一致
  /// 
  /// 返回:
  /// - [bool] 注册是否成功
  Future<bool> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return false;
    }
    
    // 检查是否选择了角色
    if (_selectedRoleId.value == null) {
      EasyLoading.showError('请选择身份');
      return false;
    }
    
    // 验证邀请码
    final inviteCode = registerInviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      EasyLoading.showError('请输入邀请码');
      return false;
    }
    
    if (!validateInviteCode(inviteCode)) {
      EasyLoading.showError('邀请码格式不正确');
      return false;
    }
    
    try {
      EasyLoading.show(status: '注册中...');
      
      final username = registerUsernameController.text.trim();
      final password = registerPasswordController.text;
      final phone = registerPhoneController.text.trim();
      final roleId = _selectedRoleId.value!;
      
      final user = await _authRepository.register(username, roleId, password, phone);
      
      // 更新用户角色
      final updatedUser = user.copyWith(roleId: roleId);
      _currentUser.value = updatedUser;
      _isLoggedIn.value = true;
      
      EasyLoading.showSuccess('注册成功');
      AppLogger.info('Registration successful for user: ${user.name}');
      
      // 清空表单
      _clearRegisterForm();
      
      // 导航到首页
      Get.offAllNamed('/home');
      return true;
      
    } on ApiResponseException catch (e) {
      // 处理所有异常（API响应、网络错误、认证错误等）
      String errorMessage = e.message;
      if (e.isRetryable) {
        errorMessage += '，请稍后重试';
      }
      EasyLoading.showError(errorMessage);
      AppLogger.error('Registration failed: ${e.message}', e);
      return false;
      
    } catch (e) {
      // 处理其他未知异常
      const errorMessage = '注册失败，请重试';
      EasyLoading.showError(errorMessage);
      AppLogger.error('Registration failed with unknown error', e);
      return false;
      
    } finally {
      EasyLoading.dismiss();
    }
  }
  
  /// 用户退出登录
  /// 
  /// 清除所有本地存储的用户信息和token
  /// 重置用户状态，导航回欢迎页
  Future<void> logout() async {
    try {
      EasyLoading.show(status: '退出中...');
      
      // 清除本地存储
      await AppServices.instance.localStorage.clearUserData();
      
      // 重置状态
      _currentUser.value = null;
      _isLoggedIn.value = false;
      
      // 清空表单
      _clearAllForms();
      
      EasyLoading.showSuccess('已退出登录');
      AppLogger.info('User logged out successfully');
      
      // 导航到欢迎页
      Get.offAllNamed('/welcome');
    } catch (e) {
      EasyLoading.showError('退出登录失败');
      AppLogger.error('Logout failed', e);
    } finally {
      EasyLoading.dismiss();
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
    _registerConfirmPasswordVisible.value = !_registerConfirmPasswordVisible.value;
  }
  
  /// 设置选择的角色
  void setSelectedRole(int roleId) {
    _selectedRoleId.value = roleId;
  }
  
  /// 获取角色名称
  String getRoleName(int roleId) {
    switch (roleId) {
      case 2:
        return '学生';
      case 3:
        return '老师';
      default:
        return '未知角色';
    }
  }
  
  /// 验证登录标识符
  /// 
  /// 参数:
  /// - [value] 输入的标识符
  /// 
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateLoginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名或邮箱';
    }
    
    value = value.trim();
    
    // 检查是否为邮箱格式
    if (value.contains('@')) {
      if (!GetUtils.isEmail(value)) {
        return '请输入有效的邮箱地址';
      }
    } else {
      // 用户名验证
      if (value.length < 3 || value.length > 50) {
        return '用户名长度应在3-50个字符之间';
      }
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
      return '请输入密码';
    }
    
    return null;
  }
  
  /// 验证用户名
  /// 
  /// 参数:
  /// - [value] 输入的用户名
  /// 
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名';
    }
    
    value = value.trim();
    
    if (value.isEmpty || value.length > 50) {
      return '用户名长度应在1-50个字符之间';
    }
    
    // 检查用户名格式（允许字母、数字、下划线、中文）
    if (!RegExp(r'^[\w\u4e00-\u9fa5]+$').hasMatch(value)) {
      return '用户名只能包含字母、数字、下划线和中文';
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
      return '请输入手机号';
    }
    
    value = value.trim();
    
    // 验证中国大陆手机号格式
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    
    return null;
  }

  /// 验证邮箱
  /// 
  /// 参数:
  /// - [value] 输入的邮箱
  /// 
  /// 返回:
  /// - [String?] 验证错误信息，null表示验证通过
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入邮箱地址';
    }
    
    value = value.trim();
    
    if (!GetUtils.isEmail(value)) {
      return '请输入有效的邮箱地址';
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
      return '请再次输入密码';
    }
    
    if (value != registerPasswordController.text) {
      return '两次输入的密码不一致';
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
    registerUsernameController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerInviteCodeController.clear();
    _selectedRoleId.value = null;
    _registerPasswordVisible.value = false;
    _registerConfirmPasswordVisible.value = false;
  }
  
  /// 清空所有表单
  void _clearAllForms() {
    _clearLoginForm();
    _clearRegisterForm();
  }
}
