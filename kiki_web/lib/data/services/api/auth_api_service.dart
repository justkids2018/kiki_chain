import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../../mock/mock_users.dart';
import '../../../config/env_config.dart';

/// 认证 API 服务
///
/// 对接 kiki_server /api/v1/auth/... 路由
/// 支持 Mock 模式和真实 API 模式切换
class AuthApiService {
  final HttpClient? _httpClient;

  AuthApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 用户登录
  ///
  /// API: POST /api/v1/auth/login
  /// 请求体: {phone, password}（明文密码）
  Future<Map<String, dynamic>> login(String phone, String password) async {
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockUsers.loginResponse(phone, password);
    }

    return await _httpClient!.post(ApiEndpoints.authLogin, data: {
      'phone': phone,
      'password': password,
    });
  }

  /// 用户注册
  ///
  /// API: POST /api/v1/auth/register
  /// 请求体: {uid, name, phone, email, password, role_type}
  Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String nickname,
  ) async {
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockUsers.registerResponse(phone, password, nickname);
    }

    return await _httpClient!.post(ApiEndpoints.authRegister, data: {
      'uid': phone,       // 用手机号作为 uid
      'name': nickname,
      'email': '',
      'phone': phone,
      'password': password,
      'role_type': 0,
    });
  }
}
