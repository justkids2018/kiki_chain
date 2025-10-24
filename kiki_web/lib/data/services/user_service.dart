import '../../core/network/request_manager.dart';

/// 用户服务 - 使用新的简洁网络层
class UserService {
  final RequestManager _request = RequestManager.instance;
  
  /// 获取用户列表
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final data = await _request.get<Map<String, dynamic>>('/users');
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      print('获取用户列表失败: $e');
      return [];
    }
  }
  
  /// 创建用户
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _request.post<Map<String, dynamic>>(
        '/users',
        data: userData,
      );
      return response['data'];
    } catch (e) {
      print('创建用户失败: $e');
      return null;
    }
  }
  
  /// 更新用户信息
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      await _request.put<Map<String, dynamic>>(
        '/users/$userId',
        data: userData,
      );
      return true;
    } catch (e) {
      print('更新用户失败: $e');
      return false;
    }
  }
  
  /// 删除用户
  Future<bool> deleteUser(int userId) async {
    try {
      await _request.delete<Map<String, dynamic>>('/users/$userId');
      return true;
    } catch (e) {
      print('删除用户失败: $e');
      return false;
    }
  }
  
  /// 获取用户详情
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final data = await _request.get<Map<String, dynamic>>('/users/$userId');
      return data['data'];
    } catch (e) {
      print('获取用户详情失败: $e');
      return null;
    }
  }
}
