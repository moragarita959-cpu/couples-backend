enum CourseOwner { me, partner }

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.startWeek,
    required this.endWeek,
    required this.repeatWeekly,
    required this.startPeriod,
    required this.endPeriod,
    required this.location,
    required this.teacher,
    required this.note,
    required this.owner,
    required this.colorHex,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final int startWeek;
  final int endWeek;
  final bool repeatWeekly;
  final int startPeriod;
  final int endPeriod;
  final String location;
  final String teacher;
  final String note;
  final CourseOwner owner;
  final String colorHex;
  final DateTime createdAt;

  bool isActiveInWeek(int weekIndex) {
    return weekIndex >= startWeek && weekIndex <= endWeek;
  }
}
