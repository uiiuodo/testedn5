import 'schedule.dart';

class DayScheduleGroups {
  final List<Schedule> normal;
  final List<Schedule> care;
  final List<Schedule> anniversary;

  DayScheduleGroups({
    required this.normal,
    required this.care,
    required this.anniversary,
  });
}
