import '../../domain/entities/course.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.weekday,
    required super.startMinute,
    required super.endMinute,
    required super.startWeek,
    required super.endWeek,
    required super.repeatWeekly,
    required super.startPeriod,
    required super.endPeriod,
    required super.location,
    required super.teacher,
    required super.note,
    required super.owner,
    required super.colorHex,
    required super.createdAt,
  });

  factory CourseModel.fromRow(CoursesTableData row) {
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
      owner: row.owner == 'partner' ? CourseOwner.partner : CourseOwner.me,
      colorHex: row.colorHex,
      createdAt: row.createdAt,
    );
  }

  factory CourseModel.fromCloudJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      weekday: json['weekday'] as int? ?? 1,
      startMinute: json['startMinute'] as int? ?? 0,
      endMinute: json['endMinute'] as int? ?? 0,
      startWeek: json['startWeek'] as int? ?? 1,
      endWeek: json['endWeek'] as int? ?? 1,
      repeatWeekly: json['repeatWeekly'] as bool? ?? true,
      startPeriod: json['startPeriod'] as int? ?? 1,
      endPeriod: json['endPeriod'] as int? ?? 1,
      location: json['location'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      note: json['note'] as String? ?? '',
      owner: (json['owner'] as String? ?? 'me') == 'partner'
          ? CourseOwner.partner
          : CourseOwner.me,
      colorHex: json['colorHex'] as String? ?? '#E88EA3',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  CoursesTableCompanion toCompanion() {
    return CoursesTableCompanion.insert(
      id: id,
      title: title,
      weekday: weekday,
      startMinute: Value<int>(startMinute),
      endMinute: Value<int>(endMinute),
      startWeek: Value<int>(startWeek),
      endWeek: Value<int>(endWeek),
      repeatWeekly: Value<bool>(repeatWeekly),
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      location: location,
      teacher: teacher,
      note: Value<String>(note),
      owner: owner == CourseOwner.partner ? 'partner' : 'me',
      colorHex: colorHex,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toCloudJson({
    required String coupleId,
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'title': title,
      'weekday': weekday,
      'startMinute': startMinute,
      'endMinute': endMinute,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'repeatWeekly': repeatWeekly,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'location': location,
      'teacher': teacher,
      'note': note,
      'owner': owner == CourseOwner.partner ? 'partner' : 'me',
      'colorHex': colorHex,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
