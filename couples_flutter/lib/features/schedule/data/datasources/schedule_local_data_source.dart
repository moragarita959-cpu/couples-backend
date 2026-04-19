import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/course_model.dart';

class ScheduleLocalDataSource {
  ScheduleLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<CourseModel>> getCourses() async {
    final rows =
        await (_db.select(_db.coursesTable)
              ..orderBy([
                (t) => OrderingTerm.asc(t.weekday),
                (t) => OrderingTerm.asc(t.startMinute),
              ]))
            .get();
    return rows.map(CourseModel.fromRow).toList();
  }

  Future<void> replaceCourses(List<CourseModel> courses) async {
    await _db.transaction(() async {
      await _db.delete(_db.coursesTable).go();
      if (courses.isEmpty) {
        return;
      }
      await _db.batch((batch) {
        batch.insertAll(_db.coursesTable, courses.map((item) => item.toCompanion()).toList());
      });
    });
  }

  Future<void> upsertCourse(CourseModel course) async {
    await _db.into(_db.coursesTable).insertOnConflictUpdate(course.toCompanion());
  }

  Future<void> deleteCourse(String id) async {
    await (_db.delete(_db.coursesTable)..where((t) => t.id.equals(id))).go();
  }
}
