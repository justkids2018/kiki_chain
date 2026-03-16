/// 应用程序API端点
/// 与 kiki_server 路由保持一致，统一使用 /api/v1/ 前缀
class ApiEndpoints {
  // 健康检查
  static const String health = '/health';

  // 认证相关 (无需认证)
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authRefreshToken = '/api/v1/auth/refresh-token';
  static const String authVerify = '/api/v1/auth/verify';
  static const String authLogout = '/api/v1/auth/logout';

  // 移动端 - 用户
  static const String userProfile = '/api/v1/mobile/user/profile';

  // 移动端 - 场景
  static const String sceneCategories = '/api/v1/mobile/scene/categories';
  static const String sceneSearch = '/api/v1/mobile/scene/search';
  static const String sceneRecommendations = '/api/v1/mobile/scene/recommendations';

  // 工具方法
  static String sceneByCategoryId(String categoryId) =>
      '/api/v1/mobile/scene/categories/$categoryId/scenes';
  static String sceneDetail(String sceneId) =>
      '/api/v1/mobile/scene/$sceneId';

  // 管理端 - 场景分类
  static const String adminSceneCategories = '/api/v1/admin/scene/categories';
  static String adminSceneCategoryById(String id) =>
      '/api/v1/admin/scene/categories/$id';

  // 管理端 - 场景
  static const String adminScenes = '/api/v1/admin/scene/scenes';
  static String adminSceneById(String id) => '/api/v1/admin/scene/scenes/$id';

  // 管理端 - 用户
  static const String adminUsers = '/api/v1/admin/users';
  static String adminUserById(String id) => '/api/v1/admin/users/$id';

  // 文件上传
  static const String uploadFile = '/api/v1/upload/file';
  static const String uploadImage = '/api/v1/upload/image';
}
