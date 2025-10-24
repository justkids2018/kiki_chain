import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../core/services/app_services.dart';

/// 简化的首页控制器
class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  // 底部导航相关
  late TabController tabController;
  final RxInt currentIndex = 0.obs;
  
  // 用户信息
  final Rxn<User> currentUser = Rxn<User>();
  
  // 服务访问
  get _authRepository => AppServices.instance.authRepository;
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化TabController
    tabController = TabController(length: 2, vsync: this);
    
    // 监听tab变化
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
      }
    });
    
    // 加载用户信息
    _loadUserInfo();
  }
  
  /// 加载用户信息
  void _loadUserInfo() async {
    try {
      // 从认证仓库获取当前用户信息
      final user = await _authRepository.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      // 如果获取失败，使用模拟数据
    }
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  /// 切换tab
  void switchTab(int index) {
    if (index != currentIndex.value) {
      tabController.animateTo(index);
      currentIndex.value = index;
    }
  }
  
  /// 登出
  void logout() async {
    try {
      // 调用认证仓库的登出方法
      await _authRepository.logout();
      // 清除用户信息
      currentUser.value = null;
    } catch (e) {
      // 处理登出错误
      print('登出失败: $e');
    }
  }
}
