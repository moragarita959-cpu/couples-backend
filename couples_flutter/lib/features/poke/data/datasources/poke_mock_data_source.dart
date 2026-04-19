import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/poke_event.dart';

class PokeMockDataSource {
  PokeMockDataSource(this._db);

  final AppDatabase _db;
  bool _seedChecked = false;

  Future<PokeEvent> sendPoke() async {
    await _ensureSeeded();
    final now = DateTime.now();
    final event = PokeEvent(
      id: 'poke-${now.microsecondsSinceEpoch}',
      sender: PokeSender.me,
      createdAt: now,
      message: '轻轻戳了TA一下',
    );
    await _db
        .into(_db.pokeEventsTable)
        .insert(
          PokeEventsTableCompanion.insert(
            id: event.id,
            sender: _senderToDbValue(event.sender),
            message: event.message,
            createdAt: event.createdAt,
          ),
        );
    return event;
  }

  Future<PokeEvent?> getLastPoke() async {
    await _ensureSeeded();
    final row =
        await (_db.select(_db.pokeEventsTable)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _rowToEntity(row);
  }

  Future<List<PokeEvent>> getPokeEvents() async {
    await _ensureSeeded();
    final rows = await (_db.select(
      _db.pokeEventsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows.map(_rowToEntity).toList();
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) {
      return;
    }
    _seedChecked = true;

    final countExpr = _db.pokeEventsTable.id.count();
    final countQuery = _db.selectOnly(_db.pokeEventsTable)
      ..addColumns([countExpr]);
    final total = await countQuery
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle();
    if (total > 0) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayMinus1 = today.subtract(const Duration(days: 1));

    await _db.batch((batch) {
      batch.insertAll(_db.pokeEventsTable, <PokeEventsTableCompanion>[
        PokeEventsTableCompanion.insert(
          id: 'poke-seed-1',
          sender: _senderToDbValue(PokeSender.me),
          message: '午休想你，轻轻戳一下',
          createdAt: dayMinus1.add(const Duration(hours: 14, minutes: 20)),
        ),
      ]);
    });
  }

  PokeEvent _rowToEntity(PokeEventsTableData row) {
    return PokeEvent(
      id: row.id,
      sender: _senderFromDbValue(row.sender),
      createdAt: row.createdAt,
      message: row.message,
    );
  }

  String _senderToDbValue(PokeSender sender) {
    return sender == PokeSender.partner ? 'partner' : 'me';
  }

  PokeSender _senderFromDbValue(String raw) {
    return raw == 'partner' ? PokeSender.partner : PokeSender.me;
  }
}
