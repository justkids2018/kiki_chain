import '../../domain/entities/user.dart';
import '../../core/network/request_manager.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/app_services.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/api_response_handler.dart';

/// 认证仓储实现
class AuthRepository {
  // 直接从AppServices获取服务实例
  final RequestManager _requestManager = RequestManager.instance;
  
  // 便捷访问器
  get _localStorage => AppServices.instance.localStorage;
  
  /// 检查服务器健康状态
  Future<bool> checkServerHealth() async {
    try {
      AppLogger.info('🏥 检查服务器健康状态...');
      final response = await _requestManager.get(ApiEndpoints.health);

      if (response != null) {
        AppLogger.info('✅ 服务器状态正常');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.warning('⚠️ 服务器不可用: $e');
      return false;
    }
  }

  /// 用户登录
  /// 
  /// 参数:
  /// - [identifier] 登录标识符，可以是手机号或邮箱
  /// - [password] 密码
  /// 
  /// 返回:
  /// - [User?] 登录成功返回用户信息，失败返回null
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
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
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
      }
      
      // 处理登录失败的情况
      final errorMessage = response['message'] ?? response['error']?['message'] ?? '登录失败';
      AppLogger.warning('❌ 登录失败: $errorMessage');
      throw ApiResponseException.fromResponse(response);
      
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
  
  /// 用户注册
  /// 
  /// 参数:
  /// - [username] 用户名，1-50个字符
  /// - [roleId] 角色ID，2=学生，3=老师
  /// - [password] 密码
  /// - [phone] 手机号
  /// 
  /// 返回:
  /// - [User?] 注册成功返回用户信息，失败返回null
  Future<User?> register(String username, int roleId, String password, String phone) async {
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
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
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
      }
      
      // 处理注册失败的情况
      throw ApiResponseException.fromResponse(response);
      
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
  
  /// 刷新访问令牌
  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _requestManager.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {
          'refresh_token': refreshToken,
        },
      );
      
      if (response['data'] != null) {
        final data = response['data'];
        
        if (data['token'] != null) {
          await _localStorage.setAccessToken(data['token']);
          
          // 如果有新的刷新token，也要更新
          if (data['refresh_token'] != null) {
            await _localStorage.setRefreshToken(data['refresh_token']);
          }
          
          AppLogger.info('Access token refreshed successfully');
          return data['token'];
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      return null;
    }
  }
  
  /// 用户登出
  Future<bool> logout() async {
    try {
      final token = await _localStorage.getAccessToken();
      
      if (token != null) {
        // 调用服务器登出接口
        await _requestManager.post<Map<String, dynamic>>(ApiEndpoints.authLogout);
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
  
  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      final userInfo = _localStorage.getUserInfo();
      
      if (userInfo != null) {
        return User.fromJson(userInfo);
      }
      
      // 如果本地没有用户信息，尝试从服务器获取
      final token = await _localStorage.getAccessToken();
      if (token != null) {
        final response = await _requestManager.get<Map<String, dynamic>>(ApiEndpoints.userProfile);
        
        if (response['data'] != null) {
          final user = User.fromJson(response['data']);
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
  
  /// 更新用户信息
  Future<User?> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      final response = await _requestManager.put<Map<String, dynamic>>(
        ApiEndpoints.userUpdate,
        data: userData,
      );
      
      if (response['data'] != null) {
        final user = User.fromJson(response['data']);
        await _localStorage.setUserInfo(user.toJson());
        
        AppLogger.info('User info updated successfully');
        return user;
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Failed to update user info', e);
      rethrow;
    }
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    return await _localStorage.getAccessToken();
  }
  
  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _localStorage.getRefreshToken();
  }
  
  /// 清除认证数据
  Future<void> clearAuthData() async {
    await _localStorage.clearAuthData();
    AppLogger.info('Auth data cleared');
  }
}
