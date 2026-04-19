class AuthUser {
  static const Object _none = Object();

  const AuthUser({
    required this.userId,
    required this.nickname,
    required this.pairCode,
    required this.createdAt,
    required this.updatedAt,
    this.coupleId,
  });

  final String userId;
  final String nickname;
  final String pairCode;
  final String? coupleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AuthUser copyWith({
    String? userId,
    String? nickname,
    String? pairCode,
    Object? coupleId = _none,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      pairCode: pairCode ?? this.pairCode,
      coupleId: identical(coupleId, _none) ? this.coupleId : coupleId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
