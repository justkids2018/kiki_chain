import '../entities/user.dart';

/// 认证仓储的领域层接口，约束数据层实现
abstract class IAuthRepository {
  /// 用户登录
  ///
  /// 参数:
  /// - [phone] 手机号（11位数字）
  /// - [password] 密码（已SHA256加密）
  Future<User?> login(String phone, String password);

  /// 用户注册
  ///
  /// 参数:
  /// - [phone] 手机号（11位数字）
  /// - [password] 密码（已SHA256加密）
  /// - [nickname] 昵称（可选，2-20字符）
  Future<User?> register(String phone, String password, {String? nickname});

  /// 验证Token是否有效
  Future<bool> verifyToken();

  /// 刷新Token
  Future<String?> refreshAccessToken();

  /// 退出登录
  Future<bool> logout();

  /// 检查服务器健康状态
  Future<bool> checkServerHealth();

  /// 获取当前用户信息
  Future<User?> getCurrentUser();

  /// 从服务端刷新当前用户信息，并更新本地缓存
  Future<User?> refreshCurrentUser();

  /// 更新用户信息
  Future<User?> updateUserInfo(Map<String, dynamic> userData);

  /// 检查是否已登录
  Future<bool> isLoggedIn();

  /// 获取访问令牌
  Future<String?> getAccessToken();

  /// 获取刷新令牌
  Future<String?> getRefreshToken();

  /// 清除认证数据
  Future<void> clearAuthData();
}
