import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/bill_records_table.dart';
import 'tables/chat_messages_table.dart';
import 'tables/countdown_events_table.dart';
import 'tables/feed_events_table.dart';
import 'tables/local_couple_profile_table.dart';
import 'tables/local_user_profile_table.dart';
import 'tables/poke_events_table.dart';
import 'tables/relationship_settings_table.dart';
import 'tables/song_reviews_table.dart';
import 'tables/songs_table.dart';
import 'tables/courses_table.dart';
import 'tables/todo_progress_table.dart';
import 'tables/todos_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    ChatMessagesTable,
    BillRecordsTable,
    CountdownEventsTable,
    PokeEventsTable,
    FeedEventsTable,
    LocalUserProfileTable,
    LocalCoupleProfileTable,
    RelationshipSettingsTable,
    CoursesTable,
    SongsTable,
    SongReviewsTable,
    TodosTable,
    TodoProgressTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(pokeEventsTable);
      }
      if (from < 3) {
        await migrator.createTable(todosTable);
        await migrator.createTable(todoProgressTable);
      }
      if (from < 4) {
        await migrator.addColumn(
          songReviewsTable,
          songReviewsTable.atmosphereScore,
        );
        await migrator.addColumn(
          songReviewsTable,
          songReviewsTable.resonanceScore,
        );
        await migrator.addColumn(songReviewsTable, songReviewsTable.shareScore);
      }
      if (from < 5) {
        await migrator.createTable(coursesTable);
      }
      if (from < 6) {
        await migrator.addColumn(coursesTable, coursesTable.startMinute);
        await migrator.addColumn(coursesTable, coursesTable.endMinute);
        await migrator.addColumn(coursesTable, coursesTable.startWeek);
        await migrator.addColumn(coursesTable, coursesTable.endWeek);
        await migrator.addColumn(coursesTable, coursesTable.repeatWeekly);
        await migrator.addColumn(coursesTable, coursesTable.note);
      }
      if (from < 7) {
        await migrator.createTable(feedEventsTable);
      }
      if (from < 8) {
        await migrator.createTable(localUserProfileTable);
        await migrator.createTable(localCoupleProfileTable);
        await migrator.addColumn(
          chatMessagesTable,
          chatMessagesTable.senderUserId,
        );
        await migrator.addColumn(
          chatMessagesTable,
          chatMessagesTable.clientMessageId,
        );
      }
      if (from < 9) {
        await migrator.addColumn(
          chatMessagesTable,
          chatMessagesTable.messageType,
        );
        await migrator.addColumn(
          chatMessagesTable,
          chatMessagesTable.mediaUrl,
        );
        await migrator.addColumn(
          chatMessagesTable,
          chatMessagesTable.mediaDurationMs,
        );
      }
      if (from < 10) {
        await migrator.createTable(relationshipSettingsTable);
      }
      if (from < 11) {
        await migrator.addColumn(songReviewsTable, songReviewsTable.styleTags);
      }
      if (from < 12) {
        await migrator.addColumn(
          billRecordsTable,
          billRecordsTable.category,
        );
      }
      if (from < 13) {
        await migrator.addColumn(
          todosTable,
          todosTable.coupleId as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          todosTable,
          todosTable.updatedAt as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          todosTable,
          todosTable.isDeleted as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          todosTable,
          todosTable.pendingSync as GeneratedColumn<Object>,
        );

        await migrator.addColumn(
          billRecordsTable,
          billRecordsTable.coupleId as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          billRecordsTable,
          billRecordsTable.updatedAt as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          billRecordsTable,
          billRecordsTable.isDeleted as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          billRecordsTable,
          billRecordsTable.pendingSync as GeneratedColumn<Object>,
        );

        await migrator.addColumn(
          countdownEventsTable,
          countdownEventsTable.coupleId as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          countdownEventsTable,
          countdownEventsTable.createdAt as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          countdownEventsTable,
          countdownEventsTable.updatedAt as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          countdownEventsTable,
          countdownEventsTable.isDeleted as GeneratedColumn<Object>,
        );
        await migrator.addColumn(
          countdownEventsTable,
          countdownEventsTable.pendingSync as GeneratedColumn<Object>,
        );

        final migrationNow = DateTime.now().toIso8601String();
        await customStatement(
          'UPDATE todos SET updated_at = created_at WHERE updated_at IS NULL',
        );
        await customStatement(
          "UPDATE bill_records SET updated_at = created_at WHERE updated_at IS NULL",
        );
        await customStatement(
          "UPDATE countdown_events SET created_at = '$migrationNow' WHERE created_at IS NULL",
        );
        await customStatement(
          "UPDATE countdown_events SET updated_at = COALESCE(updated_at, created_at, '$migrationNow') WHERE updated_at IS NULL",
        );
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'couples_local_db');
}
