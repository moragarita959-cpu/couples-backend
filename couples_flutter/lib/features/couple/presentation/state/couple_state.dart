import '../../domain/entities/couple_profile.dart';

enum CoupleStatus {
  idle,
  loading,
  bound,
  failure,
}

class CoupleState {
  const CoupleState({
    this.status = CoupleStatus.idle,
    this.profile,
    this.errorMessage,
  });

  static const Object _none = Object();

  final CoupleStatus status;
  final CoupleProfile? profile;
  final String? errorMessage;

  CoupleState copyWith({
    CoupleStatus? status,
    Object? profile = _none,
    Object? errorMessage = _none,
  }) {
    return CoupleState(
      status: status ?? this.status,
      profile: identical(profile, _none) ? this.profile : profile as CoupleProfile?,
      errorMessage: identical(errorMessage, _none)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
