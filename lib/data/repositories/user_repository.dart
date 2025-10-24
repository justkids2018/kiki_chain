import 'package:kikichain/core/constants/api_endpoints.dart';
import 'package:kikichain/core/network/request_manager.dart';
import 'package:kikichain/domain/entities/user_entity.dart';

class UserRepository {
  final RequestManager _http = RequestManager.instance;

  /// 获取教师列表，按 role_id 过滤
  Future<List<UserEntity>> fetchTeachers({int roleId = 3}) async {
    final resp = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.userList,
      queryParameters: {'role_id': roleId.toString()},
    );

    if (resp['success'] == true) {
      final data = resp['data'];
      final users = data['users'] as List<dynamic>?;
      if (users == null) return [];
      return users.map((e) => UserEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return [];
  }
}
