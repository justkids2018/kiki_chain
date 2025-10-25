import '../entities/user.dart';

/// 认证仓储的领域层接口，约束数据层实现
abstract class IAuthRepository {
  Future<User?> login(String identifier, String password);
  Future<User?> register(String username, int roleId, String password, String phone);
  Future<bool> logout();
  Future<bool> checkServerHealth();
  Future<User?> getCurrentUser();
  Future<User?> updateUserInfo(Map<String, dynamic> userData);
  Future<bool> isLoggedIn();
  Future<String?> refreshAccessToken(String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearAuthData();
}
