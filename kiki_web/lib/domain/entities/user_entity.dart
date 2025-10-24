class UserEntity {
  final String id;
  final String uid;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int roleId;

  UserEntity({
    required this.id,
    required this.uid,
    required this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
    required this.roleId,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      roleId: json['role_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'role_id': roleId,
      };
}
