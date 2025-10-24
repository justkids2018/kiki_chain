/// 应用程序API端点
class ApiEndpoints {
  // 认证相关
  // 注意：baseUrl
  static const String health = '/health';
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  
  // 用户相关
  static const String userProfile = '/api/user/profile';
  static const String userUpdate = '/api/user/update';
  
  // 生词相关
  static const String vocabularyList = '/api/vocabulary/list';
  static const String vocabularyAdd = '/api/vocabulary/add';
  static const String vocabularyUpdate = '/api/vocabulary/update';
  static const String vocabularyDelete = '/api/vocabulary/delete';
  
  // 学习相关
  static const String learningProgress = '/api/learning/progress';
  static const String learningRecord = '/api/learning/record';
  
  // 内容相关
  static const String contentList = '/api/content/list';
  static const String contentDetail = '/api/content/detail';
  
  // 文件上传
  static const String uploadFile = '/api/upload/file';
  static const String uploadImage = '/api/upload/image';
  
  // 学生作业模块
  static const String studentAssignments = '/api/student-assignments';
  static const String studentTeacherAssignments = '/api/student/teacher';
  static const String studentConversation = '/api/student/conversation';
  static const String teacherStudentAssignments = '/api/teachers';
  
  // 老师查看学生作业
  static const String getTeacherStudentAssignments = '/api/teachers/{teacher_uid}/student-assignments';
  
  // 静态资源
  static const String staticFiles = '/api/static/';
  
  // 工具方法
  static String userById(int id) => '/api/user/$id';
  // 用户列表（查询）
  static const String userList = '/api/user';
  static String vocabularyById(int id) => '/api/vocabulary/$id';
  static String contentById(int id) => '/api/content/$id';
  
  // 学生作业相关工具方法
  static String studentAssignmentById(String id) => '/api/student-assignments/$id';
  static String teacherAssignmentsByTeacherId(String teacherId) => '/api/student/teacher/$teacherId/assignments';
  static String teacherStudentAssignmentsByTeacherUid(String teacherUid) => '/api/teachers/$teacherUid/student-assignments';
}
