import 'package:kikichain/core/network/request_manager.dart';

class UserRepository {
  // ignore: unused_field
  final RequestManager _http = RequestManager.instance;

  /// 获取教师列表，按 role_id 过滤
  // Future<List<UserEntity>> fetchTeachers({int roleId = 3}) async {
  //   try {
  //     final resp = await _http.get<Map<String, dynamic>>(
  //       ApiEndpoints.userList,
  //       queryParameters: {'role_id': roleId.toString()},
  //     );
  //
  //     final data = ApiResponseHandler.handle<Map<String, dynamic>>(resp);
  //     final users = (data['users'] as List<dynamic>? ?? <dynamic>[])
  //         .map((e) => UserEntity.fromJson(e as Map<String, dynamic>))
  //         .toList();
  //
  //     return users;
  //   } on ApiResponseException {
  //     rethrow;
  //   } catch (e) {
  //     throw ApiResponseHandler.createException(e);
  //   }
  // }
}
