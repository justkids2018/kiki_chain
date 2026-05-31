import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/network/request_manager.dart';
import '../../core/network/network_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/app_services.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../config/env_config.dart';
import '../services/api/auth_api_service.dart';
import 'package:intl/intl.dart';

/// Auth 模块的数据层实现
///
/// 遵循项目统一规范：直接解析 response['success'] / response['data']，
/// 密码使用明文（与后端存储格式一致）。
class AuthRepositoryImpl implements IAuthRepository {
  final RequestManager _requestManager = RequestManager.instance;
  final AuthApiService _authApiService = AuthApiService(
    httpClient: NetworkClient.instance.httpClient,
  );

  get _localStorage => AppServices.instance.localStorage;

  @override
  Future<bool> checkServerHealth() async {
    try {
      AppLogger.info('🏥 检查服务器健康状态...');
      final response =
          await _requestManager.get<Map<String, dynamic>>(ApiEndpoints.health);
      if (response['success'] == true) {
        AppLogger.info('✅ 服务器状态正常');
        return true;
      }
      AppLogger.warning('⚠️ 服务器健康检查失败: ${response['message']}');
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

      // 明文密码（与后端数据库存储格式一致）
      final passwordToSend = EnvConfig.useMock ? password : password;

      final response = await _authApiService.login(phone, passwordToSend);

      AppLogger.info('📡 登录响应: $response');

      if (response['success'] != true) {
        throw ApiResponseException(
          message: response['message']?.toString() ?? '登录失败',
          statusCode: 401,
        );
      }

      // 后端 data 结构：{uid, name, email, phone, token, role_type, is_vip, ...}
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null) {
        throw const ApiResponseException(
          message: '登录响应缺少 token',
          statusCode: 500,
        );
      }

      await _localStorage.setAccessToken(token);
      _requestManager.setAuthToken(token);

      final user = User(
        id: data['uid'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        nickname: data['name'] as String? ?? '',
        avatar: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _localStorage.setString('user_id', user.id);
      await _localStorage.setUserInfo(user.toJson());

      AppLogger.info('✅ 用户登录成功: ${user.nickname}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('💥 登录过程出错', e, stackTrace);
      if (e is ApiResponseException) rethrow;
      throw ApiResponseException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<User?> register(String phone, String password,
      {String? nickname}) async {
    try {
      AppLogger.info('📝 尝试注册: $phone');

      // 明文密码
      final passwordToSend = password;

      final trimmedNickname = nickname?.trim() ?? '';
      final defaultNickname =
          '临时${DateFormat('yyyyMMdd').format(DateTime.now())}';

      final response = await _authApiService.register(
        phone,
        passwordToSend,
        trimmedNickname.isEmpty ? defaultNickname : trimmedNickname,
      );

      AppLogger.info('📡 注册响应: $response');

      if (response['success'] != true) {
        throw ApiResponseException(
          message: response['message']?.toString() ?? '注册失败',
          statusCode: 400,
        );
      }

      // 注册响应 data：{uid, name, email, phone, role_type, is_vip}（无 token）
      final data = response['data'] as Map<String, dynamic>;

      final user = User(
        id: data['uid'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        nickname: data['name'] as String? ?? '',
        avatar: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _localStorage.setString('user_id', user.id);
      await _localStorage.setUserInfo(user.toJson());

      // 注册成功后自动登录以获取 token
      try {
        final loginResponse =
            await _authApiService.login(phone, passwordToSend);
        if (loginResponse['success'] == true) {
          final loginData = loginResponse['data'] as Map<String, dynamic>;
          final token = loginData['token'] as String?;
          if (token != null) {
            await _localStorage.setAccessToken(token);
            _requestManager.setAuthToken(token);
          }
        }
      } catch (_) {
        // 自动登录失败不影响注册成功结果
      }

      AppLogger.info('✅ 用户注册成功: ${user.nickname}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('💥 注册过程出错', e, stackTrace);
      if (e is ApiResponseException) rethrow;
      throw ApiResponseException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> verifyToken() async {
    try {
      final token = await _localStorage.getAccessToken();
      if (token == null || token.isEmpty) return false;

      final response = await _requestManager
          .get<Map<String, dynamic>>(ApiEndpoints.authVerify);

      if (response['success'] != true) return false;

      final data = response['data'] as Map<String, dynamic>?;
      final valid = data?['valid'] as bool? ?? false;

      AppLogger.info(valid ? '✅ Token验证成功' : '⚠️ Token已失效');
      return valid;
    } catch (e) {
      AppLogger.error('Token验证失败', e);
      return false;
    }
  }

  @override
  Future<String?> refreshAccessToken() async {
    try {
      final response = await _requestManager
          .post<Map<String, dynamic>>(ApiEndpoints.authRefreshToken);

      if (response['success'] != true) return null;

      final data = response['data'] as Map<String, dynamic>?;
      final newToken = data?['token'] as String?;

      if (newToken != null) {
        await _localStorage.setAccessToken(newToken);
        _requestManager.setAuthToken(newToken);
        AppLogger.info('✅ Token刷新成功');
      }

      return newToken;
    } catch (e) {
      AppLogger.error('Token刷新失败', e);
      if (e is ApiResponseException) rethrow;
      throw ApiResponseException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final token = await _localStorage.getAccessToken();
      if (token != null) {
        await _requestManager
            .post<Map<String, dynamic>>(ApiEndpoints.authLogout);
      }
      await _localStorage.clearAuthData();
      AppLogger.info('User logged out successfully');
      return true;
    } catch (e) {
      AppLogger.error('Logout failed', e);
      await _localStorage.clearAuthData();
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userInfo = _localStorage.getUserInfo();
      if (userInfo != null) return User.fromJson(userInfo);

      final token = await _localStorage.getAccessToken();
      if (token != null) {
        final response = await _requestManager
            .get<Map<String, dynamic>>(ApiEndpoints.userProfile);

        if (response['success'] == true) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null && data.isNotEmpty) {
            final user = User.fromJson(data);
            await _localStorage.setUserInfo(user.toJson());
            return user;
          }
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

      if (response['success'] != true) {
        throw ApiResponseException(
          message: response['message']?.toString() ?? '更新失败',
          statusCode: 400,
        );
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data.isNotEmpty) {
        final user = User.fromJson(data);
        await _localStorage.setUserInfo(user.toJson());
        AppLogger.info('User info updated successfully');
        return user;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to update user info', e);
      if (e is ApiResponseException) rethrow;
      throw ApiResponseException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getAccessToken() async =>
      await _localStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() async =>
      await _localStorage.getRefreshToken();

  @override
  Future<void> clearAuthData() async {
    await _localStorage.clearAuthData();
    AppLogger.info('Auth data cleared');
  }
}
