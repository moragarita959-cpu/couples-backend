import '../repositories/countdown_repository.dart';

class SaveCountdownSettings {
  const SaveCountdownSettings(this._repository);

  final CountdownRepository _repository;

  Future<void> call({
    DateTime? loveStartDate,
    int? loveDaysOverride,
  }) {
    return _repository.saveSettings(
      loveStartDate: loveStartDate,
      loveDaysOverride: loveDaysOverride,
    );
  }
}
