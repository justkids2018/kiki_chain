import 'package:qiqimanyou/core/network/request_manager.dart';

/// TeacherStudentRelationApi encapsulates CRUD operations for teacher-student bindings.
class TeacherStudentRelationApi {
  TeacherStudentRelationApi({RequestManager? requestManager})
      : _requestManager = requestManager ?? RequestManager.instance;

  final RequestManager _requestManager;

  /// Query relationships filtered by teacher and/or student uid.
  /// At least one parameter must be provided.
  Future<Map<String, dynamic>> fetchRelations({
    String? teacherUid,
    String? studentUid,
  }) async {
    if (teacherUid == null && studentUid == null) {
      throw ArgumentError('teacherUid or studentUid must be provided');
    }

    final queryParameters = <String, String>{
      if (teacherUid != null) 'teacher_uid': teacherUid,
      if (studentUid != null) 'student_uid': studentUid,
    };

    final resp = await _requestManager.get<Map<String, dynamic>>(
      '/api/teacher-student',
      queryParameters: queryParameters,
    );
    return resp['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  /// Bind a student to a teacher, optionally setting as default.
  Future<Map<String, dynamic>> createRelation({
    required String teacherUid,
    required String studentUid,
    bool setDefault = false,
  }) async {
    final resp = await _requestManager.post<Map<String, dynamic>>(
      '/api/teacher-student',
      data: {
        'teacher_uid': teacherUid,
        'student_uid': studentUid,
        if (setDefault) 'set_default': setDefault,
      },
    );
    return resp['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  /// Update a student's teacher binding, moving from current to new teacher.
  Future<Map<String, dynamic>> updateRelation({
    required String studentUid,
    required String currentTeacherUid,
    required String newTeacherUid,
    bool? setDefault,
  }) async {
    final body = {
      'student_uid': studentUid,
      'current_teacher_uid': currentTeacherUid,
      'new_teacher_uid': newTeacherUid,
      if (setDefault != null) 'set_default': setDefault,
    };

    final resp = await _requestManager.put<Map<String, dynamic>>(
      '/api/teacher-student',
      data: body,
    );
    return resp['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  /// Remove binding between a teacher and a student.
  Future<Map<String, dynamic>> deleteRelation({
    required String teacherUid,
    required String studentUid,
  }) async {
    final resp = await _requestManager.delete<Map<String, dynamic>>(
      '/api/teacher-student',
      queryParameters: {
        'teacher_uid': teacherUid,
        'student_uid': studentUid,
      },
    );
    return resp['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}
