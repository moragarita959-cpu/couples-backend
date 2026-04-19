class CoupleProfile {
  const CoupleProfile({
    required this.coupleId,
    required this.currentUserId,
    required this.currentUserNickname,
    required this.partnerUserId,
    required this.partnerNickname,
    required this.createdAt,
    required this.updatedAt,
  });

  final String coupleId;
  final String currentUserId;
  final String currentUserNickname;
  final String partnerUserId;
  final String partnerNickname;
  final DateTime createdAt;
  final DateTime updatedAt;
}
