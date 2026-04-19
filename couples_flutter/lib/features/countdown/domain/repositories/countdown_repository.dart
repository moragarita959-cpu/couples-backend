import '../entities/countdown_settings.dart';
import '../entities/countdown_event.dart';

abstract class CountdownRepository {
  Future<List<CountdownEvent>> loadAll({required String coupleId});
  Future<List<CountdownEvent>> refresh({required String coupleId});
  Future<CountdownEvent> insert(CountdownEvent event);
  Future<CountdownEvent> update(CountdownEvent event);
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  });

  Future<CountdownSettings> getSettings();

  Future<void> saveSettings({
    DateTime? loveStartDate,
    int? loveDaysOverride,
  });

  Future<CountdownEvent> addEvent(String name, DateTime date);
  Future<CountdownEvent> updateEvent(String id, String name, DateTime date);
  Future<void> deleteEvent(String id);
  Future<List<CountdownEvent>> getEvents();
}
