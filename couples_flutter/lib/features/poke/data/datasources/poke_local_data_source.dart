import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/poke_event.dart';

class PokeLocalDataSource {
  PokeLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<PokeEvent>> getPokeEvents() async {
    final rows = await (_db.select(
      _db.pokeEventsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows
        .map(
          (row) => PokeEvent(
            id: row.id,
            sender: row.sender == 'partner' ? PokeSender.partner : PokeSender.me,
            createdAt: row.createdAt,
            message: row.message,
          ),
        )
        .toList();
  }

  Future<void> replacePokeEvents(List<PokeEvent> events) async {
    await _db.transaction(() async {
      await _db.delete(_db.pokeEventsTable).go();
      if (events.isEmpty) {
        return;
      }
      await _db.batch((batch) {
        batch.insertAll(
          _db.pokeEventsTable,
          events
              .map(
                (event) => PokeEventsTableCompanion.insert(
                  id: event.id,
                  sender: event.sender == PokeSender.partner ? 'partner' : 'me',
                  message: event.message,
                  createdAt: event.createdAt,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<void> upsertPokeEvent(PokeEvent event) async {
    await _db.into(_db.pokeEventsTable).insertOnConflictUpdate(
          PokeEventsTableCompanion.insert(
            id: event.id,
            sender: event.sender == PokeSender.partner ? 'partner' : 'me',
            message: event.message,
            createdAt: event.createdAt,
          ),
        );
  }
}
