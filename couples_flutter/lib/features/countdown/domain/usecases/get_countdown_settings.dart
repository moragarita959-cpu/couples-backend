import '../entities/countdown_settings.dart';
import '../repositories/countdown_repository.dart';

class GetCountdownSettings {
  const GetCountdownSettings(this._repository);

  final CountdownRepository _repository;

  Future<CountdownSettings> call() {
    return _repository.getSettings();
  }
}
