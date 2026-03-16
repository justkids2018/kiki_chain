import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/network/request_manager.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/app_services.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/api_response_handler.dart';
import '../../utils/crypto_utils.dart';
import '../../config/env_config.dart';
import '../services/api/auth_api_service.dart';

/// Auth 模块的数据层实现
class AuthRepositoryImpl implements IAuthRepository {
  // 直接从 AppServices 获取依赖，保持现有单例结构
  final RequestManager _requestManager = RequestManager.instance;
  final AuthApiService _authApiService = AuthApiService();

  // 便捷访问器
  get _localStorage => AppServices.instance.localStorage;

  @override
  Future<bool> checkServerHealth() async {
    try {
      AppLogger.info('🏥 检查服务器健康状态...');
      final response = await _requestManager
          .get<Map<String, dynamic>>(ApiEndpoints.health);
      final result = ApiResponseHandler.handleSafe<dynamic>(response);

      if (result.isSuccess) {
        AppLogger.info('✅ 服务器状态正常');
        return true;
      }
      AppLogger.warning('⚠️ 服务器健康检查失败: ${result.message}');
      return false;
    } catch (e) {
      AppLogger.warning('⚠️ 服务器不可用: $e');
      return false;
    }
  }

  @override
  Future<User?> login(String phone, String password) async {
    try {
      AppLogger.info('🔐 尝试登录: $phone');

      // Mock模式下使用明文密码，真实API使用SHA256加密
      final passwordToSend = EnvConfig.useMock
          ? password
          : CryptoUtils.sha256Encrypt(password);

      // 调用登录接口（使用 AuthApiService，自动处理 Mock/真实 API）
      final response = await _authApiService.login(phone, passwordToSend);

      AppLogger.info('📡 登录响应: $response');

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      // 提取用户数据和token
      final userData = data['user'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      final expiresAt = data['expiresAt'] as String?;

      if (userData == null || token == null) {
        throw const ApiResponseException(
          message: '登录响应数据格式错误',
          statusCode: 500,
        );
      }

      // 存储token和过期时间
      await _localStorage.setAccessToken(token);
      if (expiresAt != null) {
        await _localStorage.setString('token_expires_at', expiresAt);
      }
      _requestManager.setAuthToken(token);

      // 创建用户对象
      final user = User(
        id: userData['id'] as String? ?? '',
        phone: userData['phone'] as String? ?? '',
        nickname: userData['nickname'] as String? ?? '',
        avatar: userData['avatar'] as String?,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'])
            : DateTime.now(),
        lastLoginAt: userData['lastLoginAt'] != null
            ? DateTime.parse(userData['lastLoginAt'])
            : DateTime.now(),
      );

      // 存储用户信息
      await _localStorage.setString('user_id', user.id);
      await _localStorage.setUserInfo(user.toJson());

      AppLogger.info('✅ 用户登录成功: ${user.nickname}');
      return user;
    } catch (e) {
      AppLogger.error('💥 登录过程出错', e);

      if (e is ApiResponseException) {
        rethrow;
      }

      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<User?> register(String phone, String password, {String? nickname}) async {
    try {
      AppLogger.info('📝 尝试注册: $phone');

      // Mock模式下使用明文密码，真实API使用SHA256加密
      final passwordToSend = EnvConfig.useMock
          ? password
          : CryptoUtils.sha256Encrypt(password);

      // 调用注册接口（使用 AuthApiService，自动处理 Mock/真实 API）
      final response = await _authApiService.register(
        phone,
        passwordToSend,
        nickname ?? phone,
      );

      AppLogger.info('📡 注册响应: $response');

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      // 提取用户数据和token
      final userData = data['user'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      final expiresAt = data['expiresAt'] as String?;

      if (userData == null || token == null) {
        throw const ApiResponseException(
          message: '注册响应数据格式错误',
          statusCode: 500,
        );
      }

      // 存储token和过期时间
      await _localStorage.setAccessToken(token);
      if (expiresAt != null) {
        await _localStorage.setString('token_expires_at', expiresAt);
      }
      _requestManager.setAuthToken(token);

      // 创建用户对象
      final user = User(
        id: userData['id'] as String? ?? '',
        phone: userData['phone'] as String? ?? '',
        nickname: userData['nickname'] as String? ?? '',
        avatar: userData['avatar'] as String?,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'])
            : DateTime.now(),
        lastLoginAt: userData['lastLoginAt'] != null
            ? DateTime.parse(userData['lastLoginAt'])
            : DateTime.now(),
      );

      // 存储用户信息
      await _localStorage.setString('user_id', user.id);
      await _localStorage.setUserInfo(user.toJson());

      AppLogger.info('✅ 用户注册成功: ${user.nickname}');
      return user;
    } catch (e) {
      AppLogger.error('💥 注册过程出错', e);

      if (e is ApiResponseException) {
        rethrow;
      }

      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<bool> verifyToken() async {
    try {
      final token = await _localStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await _requestManager.get<Map<String, dynamic>>(
        ApiEndpoints.authVerify,
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      final valid = data['valid'] as bool? ?? false;
      if (valid) {
        final expiresAt = data['expiresAt'] as String?;
        if (expiresAt != null) {
          await _localStorage.setString('token_expires_at', expiresAt);
        }
        AppLogger.info('✅ Token验证成功');
      } else {
        AppLogger.warning('⚠️ Token已失效');
      }

      return valid;
    } catch (e) {
      AppLogger.error('Token验证失败', e);
      return false;
    }
  }

  @override
  Future<String?> refreshAccessToken() async {
    try {
      final response = await _requestManager.post<Map<String, dynamic>>(
        ApiEndpoints.authRefreshToken,
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      final newToken = data['token'] as String?;
      final expiresAt = data['expiresAt'] as String?;

      if (newToken != null) {
        await _localStorage.setAccessToken(newToken);
        _requestManager.setAuthToken(newToken);

        if (expiresAt != null) {
          await _localStorage.setString('token_expires_at', expiresAt);
        }

        AppLogger.info('✅ Token刷新成功');
        return newToken;
      }

      return null;
    } catch (e) {
      AppLogger.error('Token刷新失败', e);

      if (e is ApiResponseException) {
        rethrow;
      }

      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final token = await _localStorage.getAccessToken();

      if (token != null) {
        // 调用服务器登出接口并校验响应
        final response = await _requestManager
            .post<Map<String, dynamic>>(ApiEndpoints.authLogout);
        ApiResponseHandler.handle<dynamic>(response);
      }

      // 清除本地认证数据
      await _localStorage.clearAuthData();

      AppLogger.info('User logged out successfully');
      return true;
    } catch (e) {
      AppLogger.error('Logout failed', e);

      // 即使服务器登出失败，也要清除本地数据
      await _localStorage.clearAuthData();
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userInfo = _localStorage.getUserInfo();

      if (userInfo != null) {
        return User.fromJson(userInfo);
      }

      // 如果本地没有用户信息，尝试从服务器获取
      final token = await _localStorage.getAccessToken();
      if (token != null) {
        final response = await _requestManager
            .get<Map<String, dynamic>>(ApiEndpoints.userProfile);
        final data =
            ApiResponseHandler.handle<Map<String, dynamic>?>(response);

        if (data != null && data.isNotEmpty) {
          final user = User.fromJson(data);
          await _localStorage.setUserInfo(user.toJson());
          return user;
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return null;
    }
  }

  @override
  Future<User?> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      final response = await _requestManager.put<Map<String, dynamic>>(
        ApiEndpoints.userProfile,
        data: userData,
      );

      final data =
          ApiResponseHandler.handle<Map<String, dynamic>?>(response);

      if (data != null && data.isNotEmpty) {
        final user = User.fromJson(data);
        await _localStorage.setUserInfo(user.toJson());

        AppLogger.info('User info updated successfully');
        return user;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to update user info', e);
      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getAccessToken() async {
    return await _localStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _localStorage.getRefreshToken();
  }

  @override
  Future<void> clearAuthData() async {
    await _localStorage.clearAuthData();
    AppLogger.info('Auth data cleared');
  }
}
