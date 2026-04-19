import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.userId,
    required super.nickname,
    required super.pairCode,
    required super.createdAt,
    required super.updatedAt,
    super.coupleId,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      userId: json['id'] as String,
      nickname: json['nickname'] as String,
      pairCode: json['pairCode'] as String,
      coupleId: json['coupleId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
