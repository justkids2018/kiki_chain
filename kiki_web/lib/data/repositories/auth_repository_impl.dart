import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/network/request_manager.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/app_services.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/api_response_handler.dart';

/// Auth 模块的数据层实现，保持与旧版 AuthRepository 等价的行为
class AuthRepositoryImpl implements IAuthRepository {
  // 直接从 AppServices 获取依赖，保持现有单例结构
  final RequestManager _requestManager = RequestManager.instance;

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
  Future<User?> login(String identifier, String password) async {
    try {
      AppLogger.info('🔐 尝试登录: $identifier');

      // 服务器可用，进行正常登录
      final response = await _requestManager.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      AppLogger.info('📡 登录响应: $response');

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      // 存储token
      if (data['token'] != null) {
        await _localStorage.setAccessToken(data['token']);
        _requestManager.setAuthToken(data['token']); // 设置到网络层
      }

      // 创建用户对象
      final user = User(
        id: int.tryParse(data['uid']?.toString() ?? '') ?? 0,
        uid: data['uid'] ?? '',
        name: data['name'] ?? data['username'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : DateTime.now(),
        roleId: int.tryParse(data['role_id']?.toString() ?? '') ?? 2,
      );

      // 存储用户信息
      await _localStorage.setUserId(user.id);
      await _localStorage.setUserInfo(user.toJson());

      AppLogger.info('✅ 用户登录成功: ${user.name}');
      return user;
    } catch (e) {
      AppLogger.error('💥 登录过程出错', e);

      // 如果已经是 ApiResponseException，直接重新抛出
      if (e is ApiResponseException) {
        rethrow;
      }

      // 否则转换为 ApiResponseException
      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<User?> register(
      String username, int roleId, String password, String phone) async {
    try {
      final response = await _requestManager.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: {
          'username': username,
          'role_id': roleId,
          'password': password,
          'phone': phone,
        },
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      // 存储token
      if (data['token'] != null) {
        await _localStorage.setAccessToken(data['token']);
        _requestManager.setAuthToken(data['token']);
      }

      // 创建用户对象
      final user = User(
        id: int.tryParse(data['id']?.toString() ?? '') ?? 0,
        uid: data['uid'] ?? '',
        name: data['name'] ?? data['username'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'])
            : DateTime.now(),
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : DateTime.now(),
        roleId: int.tryParse(data['role_id']?.toString() ?? '') ?? 2,
      );

      // 存储用户信息
      await _localStorage.setUserId(user.id);
      await _localStorage.setUserInfo(user.toJson());

      AppLogger.info('User registered successfully: ${user.name}');
      return user;
    } catch (e) {
      AppLogger.error('Registration failed');

      // 如果已经是 ApiResponseException，直接重新抛出
      if (e is ApiResponseException) {
        rethrow;
      }

      // 否则转换为 ApiResponseException
      throw ApiResponseHandler.createException(e);
    }
  }

  @override
  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _requestManager.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {
          'refresh_token': refreshToken,
        },
      );

      final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

      if (data['token'] != null) {
        await _localStorage.setAccessToken(data['token']);

        // 如果有新的刷新token，也要更新
        if (data['refresh_token'] != null) {
          await _localStorage.setRefreshToken(data['refresh_token']);
        }

        AppLogger.info('Access token refreshed successfully');
        return data['token'];
      }

      return null;
    } catch (e) {
      AppLogger.error('Token refresh failed', e);

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
        ApiEndpoints.userUpdate,
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
