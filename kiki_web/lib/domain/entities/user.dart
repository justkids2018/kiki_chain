/// 用户实体
///
/// 对应API响应结构 (doc/api/auth.md):
/// - id: 用户唯一标识符 (String类型，如 "usr_1a2b3c4d")
/// - phone: 手机号
/// - nickname: 用户昵称
/// - avatar: 头像URL（可选）
/// - createdAt: 创建时间
/// - lastLoginAt: 最后登录时间
class User {
  final String id;
  final String phone;
  final String nickname;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatar,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// 从 JSON 创建 User 实例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  /// 创建用户副本
  User copyWith({
    String? id,
    String? phone,
    String? nickname,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, phone: $phone, nickname: $nickname, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
           other.id == id &&
           other.phone == phone &&
           other.nickname == nickname;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           phone.hashCode ^
           nickname.hashCode;
  }
}
