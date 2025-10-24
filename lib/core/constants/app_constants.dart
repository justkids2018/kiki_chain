/// 应用程序常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'Kiki World';
  static const String appVersion = '1.0.0';

  // 网络配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 存储键
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserInfo = 'user_info';
  static const String keyEnvironment = 'environment';
  static const String keyBaseUrl = 'base_url';
  static const String keyChatDifyArguments = 'chat_dify_arguments';

  // 路由名称
  static const String routeHome = '/home';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeProfile = '/profile';
  static const String routeWebView = '/webview';
  static const String routeWelcome = '/welcome';
  static const String routeOnboarding = '/onboarding';
  static const String routeChat = '/chat';
  static const String routeChatDify = '/chat/dify';
  static const String routeTeacherChat = '/teacher/chat';
  static const String debugDio = '/test/dio';

  // 默认值
  static const int defaultPageSize = 20;
  static const int maxRetryCount = 3;

  // 平台相关
  static const String platformChannelName = 'kikichain/platform';

  static const String defaultReplaceKey = 'Qmm';

  // 错误消息
  static const String errorNetworkConnection = '网络连接失败，请检查网络';
  static const String errorTimeout = '请求超时，请重试';
  static const String errorUnknown = '未知错误';
  static const String errorUnauthorized = '未授权，请重新登录';
  static const String errorForbidden = '禁止访问';
  static const String errorNotFound = '资源不存在';
  static const String errorServerError = '服务器错误';
}
