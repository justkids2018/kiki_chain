import '../../../config/env_config.dart';
import '../../../core/network/http_client.dart';
import '../../mock/mock_users.dart';

/// 认证 API 服务
///
/// 负责认证相关的所有 API 调用
/// 支持 Mock 模式和真实 API 模式切换
class AuthApiService {
  final HttpClient? _httpClient;

  AuthApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 用户登录
  ///
  /// 对应 API: POST /auth/login
  /// Mock: MockUsers.loginResponse(phone, password)
  ///
  /// [phone] 手机号
  /// [password] 密码（Mock模式使用明文，真实API使用加密后的密码）
  Future<Map<String, dynamic>> login(String phone, String password) async {
    if (EnvConfig.useMock) {
      // Mock 模式：返回本地数据
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
      return MockUsers.loginResponse(phone, password);
    }

    // 真实 API 模式
    return await _httpClient!.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
  }

  /// 用户注册
  ///
  /// 对应 API: POST /auth/register
  /// Mock: MockUsers.registerResponse(phone, password, nickname)
  ///
  /// [phone] 手机号
  /// [password] 密码（Mock模式使用明文，真实API使用加密后的密码）
  /// [nickname] 昵称
  Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String nickname,
  ) async {
    if (EnvConfig.useMock) {
      // Mock 模式
      await Future.delayed(const Duration(milliseconds: 500));
      return MockUsers.registerResponse(phone, password, nickname);
    }

    // 真实 API 模式
    return await _httpClient!.post('/auth/register', data: {
      'phone': phone,
      'password': password,
      'nickname': nickname,
    });
  }
}
