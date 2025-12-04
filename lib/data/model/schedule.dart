import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 6)
enum ScheduleType {
  @HiveField(0)
  anniversary,
  @HiveField(1)
  care,
  @HiveField(2)
  etc,
}

@HiveType(typeId: 7)
class Schedule {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startDateTime;

  @HiveField(3)
  final DateTime endDateTime;

  @HiveField(4)
  final bool allDay;

  @HiveField(5)
  final ScheduleType type;

  @HiveField(6)
  final List<String> personIds;

  @HiveField(7)
  final String? groupId;

  @HiveField(8)
  final bool isPlanned;

  Schedule({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    required this.allDay,
    required this.type,
    required this.personIds,
    this.groupId,
    this.isPlanned = false,
  });
}
