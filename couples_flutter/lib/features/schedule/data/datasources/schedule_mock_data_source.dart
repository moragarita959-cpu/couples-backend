import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/course.dart';
import '../models/course_model.dart';

class ScheduleMockDataSource {
  ScheduleMockDataSource(this._db);

  final AppDatabase _db;
  bool _seedChecked = false;

  Future<List<CourseModel>> getCourses() async {
    await _ensureSeeded();
    final rows =
        await (_db.select(_db.coursesTable)..orderBy([
              (t) => OrderingTerm.asc(t.weekday),
              (t) => OrderingTerm.asc(t.startMinute),
            ]))
            .get();
    return rows.map(_rowToModel).toList();
  }

  Future<CourseModel> addCourse({
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required int startPeriod,
    required int endPeriod,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Course title is required');
    }
    if (weekday < 1 || weekday > 7) {
      throw Exception('Weekday must be between 1 and 7');
    }
    if (startMinute < 0 || endMinute <= startMinute) {
      throw Exception('Time range is invalid');
    }
    if (startWeek <= 0 || endWeek < startWeek) {
      throw Exception('Week range is invalid');
    }

    final now = DateTime.now();
    final model = CourseModel(
      id: 'course-${now.microsecondsSinceEpoch}',
      title: trimmedTitle,
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
      repeatWeekly: repeatWeekly,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      location: location.trim(),
      teacher: teacher.trim(),
      note: note.trim(),
      owner: owner,
      colorHex: colorHex,
      createdAt: now,
    );

    await _db.into(_db.coursesTable).insert(
          CoursesTableCompanion.insert(
            id: model.id,
            title: model.title,
            weekday: model.weekday,
            startMinute: Value(model.startMinute),
            endMinute: Value(model.endMinute),
            startWeek: Value(model.startWeek),
            endWeek: Value(model.endWeek),
            repeatWeekly: Value(model.repeatWeekly),
            startPeriod: model.startPeriod,
            endPeriod: model.endPeriod,
            location: model.location,
            teacher: model.teacher,
            note: Value(model.note),
            owner: _ownerToDbValue(model.owner),
            colorHex: model.colorHex,
            createdAt: model.createdAt,
          ),
        );

    return model;
  }

  Future<CourseModel> updateCourse({
    required String id,
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required int startPeriod,
    required int endPeriod,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Course title is required');
    }
    if (weekday < 1 || weekday > 7) {
      throw Exception('Weekday must be between 1 and 7');
    }
    if (startMinute < 0 || endMinute <= startMinute) {
      throw Exception('Time range is invalid');
    }
    if (startWeek <= 0 || endWeek < startWeek) {
      throw Exception('Week range is invalid');
    }

    final oldRow = await (_db.select(
      _db.coursesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (oldRow == null) {
      throw Exception('Course not found');
    }

    await (_db.update(_db.coursesTable)..where((t) => t.id.equals(id))).write(
      CoursesTableCompanion(
        title: Value(trimmedTitle),
        weekday: Value(weekday),
        startMinute: Value(startMinute),
        endMinute: Value(endMinute),
        startWeek: Value(startWeek),
        endWeek: Value(endWeek),
        repeatWeekly: Value(repeatWeekly),
        startPeriod: Value(startPeriod),
        endPeriod: Value(endPeriod),
        location: Value(location.trim()),
        teacher: Value(teacher.trim()),
        note: Value(note.trim()),
        owner: Value(_ownerToDbValue(owner)),
        colorHex: Value(colorHex),
      ),
    );

    final updatedRow = await (_db.select(
      _db.coursesTable,
    )..where((t) => t.id.equals(id))).getSingle();
    return _rowToModel(updatedRow);
  }

  Future<void> deleteCourse(String id) async {
    await (_db.delete(_db.coursesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) {
      return;
    }
    _seedChecked = true;

    final countExpr = _db.coursesTable.id.count();
    final countQuery = _db.selectOnly(_db.coursesTable)..addColumns([countExpr]);
    final total = await countQuery.map((row) => row.read(countExpr) ?? 0).getSingle();
    if (total > 0) {
      return;
    }

    final now = DateTime.now();
    final seed = <CoursesTableCompanion>[
      CoursesTableCompanion.insert(
        id: 'course-seed-1',
        title: '线性代数',
        weekday: 1,
        startMinute: Value(_timeToMinute(8, 0)),
        endMinute: Value(_timeToMinute(9, 35)),
        startWeek: const Value(1),
        endWeek: const Value(16),
        repeatWeekly: const Value(true),
        startPeriod: 1,
        endPeriod: 2,
        location: '教学楼 A201',
        teacher: '王老师',
        note: const Value(''),
        owner: _ownerToDbValue(CourseOwner.me),
        colorHex: '#E88EA3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CoursesTableCompanion.insert(
        id: 'course-seed-2',
        title: '程序设计',
        weekday: 3,
        startMinute: Value(_timeToMinute(10, 20)),
        endMinute: Value(_timeToMinute(11, 55)),
        startWeek: const Value(1),
        endWeek: const Value(18),
        repeatWeekly: const Value(true),
        startPeriod: 3,
        endPeriod: 4,
        location: '实验楼 302',
        teacher: '赵老师',
        note: const Value(''),
        owner: _ownerToDbValue(CourseOwner.partner),
        colorHex: '#6A9DE8',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CoursesTableCompanion.insert(
        id: 'course-seed-3',
        title: '英语口语',
        weekday: 5,
        startMinute: Value(_timeToMinute(14, 30)),
        endMinute: Value(_timeToMinute(16, 0)),
        startWeek: const Value(3),
        endWeek: const Value(12),
        repeatWeekly: const Value(true),
        startPeriod: 7,
        endPeriod: 8,
        location: '文科楼 101',
        teacher: 'Lin',
        note: const Value('小组展示周需要提前到教室'),
        owner: _ownerToDbValue(CourseOwner.me),
        colorHex: '#A985E8',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];

    await _db.batch((batch) {
      batch.insertAll(_db.coursesTable, seed);
    });
  }

  CourseModel _rowToModel(CoursesTableData row) {
    return CourseModel(
      id: row.id,
      title: row.title,
      weekday: row.weekday,
      startMinute: row.startMinute,
      endMinute: row.endMinute,
      startWeek: row.startWeek,
      endWeek: row.endWeek,
      repeatWeekly: row.repeatWeekly,
      startPeriod: row.startPeriod,
      endPeriod: row.endPeriod,
      location: row.location,
      teacher: row.teacher,
      note: row.note,
      owner: _ownerFromDbValue(row.owner),
      colorHex: row.colorHex,
      createdAt: row.createdAt,
    );
  }

  String _ownerToDbValue(CourseOwner owner) {
    return owner == CourseOwner.partner ? 'partner' : 'me';
  }

  CourseOwner _ownerFromDbValue(String raw) {
    return raw == 'partner' ? CourseOwner.partner : CourseOwner.me;
  }

  static int _timeToMinute(int hour, int minute) => hour * 60 + minute;
}
