/// 用户实体
/// 
/// 对应数据库表结构:
/// - id: 主键，自增ID
/// - uid: 用户唯一标识符
/// - name: 用户名，唯一
/// - pwd: 密码（不在实体中存储明文）
/// - email: 邮箱，唯一
/// - phone: 手机号，唯一
/// - created_at: 创建时间
/// - updated_at: 更新时间
/// - role_id: 角色ID
class User {
  final int id;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int roleId;
  
  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.roleId, 
  });
  
  /// 从 JSON 创建 User 实例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      roleId: json['role_id'] ?? 1, // 默认角色ID为1（学生）
    );
  }
  
  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'role_id': roleId,
    };
  }
  
  /// 创建用户副本
  User copyWith({
    int? id,
    String? uid,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? roleId,
  }) {
    return User(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roleId: roleId ?? this.roleId,
    );
  }
  
  /// 获取用户角色名称
  String get roleName {
    switch (roleId) {
      case 1:
        return '管理员';
      case 2:
        return '学生';
      case 3:
        return '老师'; // 根据你的业务需求，可能与教师不同
      default:
        return '未知角色';
    }
  }
  
  /// 检查是否为教师
  bool get isTeacher =>  roleId == 3;
  
  /// 检查是否为学生
  bool get isStudent => roleId == 2;
  
  /// 检查是否为管理员
  bool get isAdmin => roleId == 1;
  
  @override
  String toString() {
    return 'User(id: $id, user_id: $uid, name: $name, email: $email, phone: $phone, roleId: $roleId)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
           other.id == id &&
           other.uid == uid &&
           other.name == name &&
           other.email == email;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ 
           uid.hashCode ^ 
           name.hashCode ^ 
           email.hashCode;
  }
}
