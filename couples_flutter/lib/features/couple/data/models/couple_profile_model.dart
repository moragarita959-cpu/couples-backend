import '../../domain/entities/couple_profile.dart';

class CoupleProfileModel extends CoupleProfile {
  const CoupleProfileModel({
    required super.coupleId,
    required super.currentUserId,
    required super.currentUserNickname,
    required super.partnerUserId,
    required super.partnerNickname,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CoupleProfileModel.fromJson(Map<String, dynamic> json) {
    return CoupleProfileModel(
      coupleId: json['coupleId'] as String,
      currentUserId: json['currentUser']['id'] as String,
      currentUserNickname: json['currentUser']['nickname'] as String,
      partnerUserId: json['partner']['id'] as String,
      partnerNickname: json['partner']['nickname'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
