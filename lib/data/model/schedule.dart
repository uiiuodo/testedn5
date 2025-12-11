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

  @HiveField(9)
  final String repeatType; // NONE, DAILY, WEEKLY, MONTHLY, YEARLY

  @HiveField(10)
  final int? alarmOffsetMinutes; // null = none

  @HiveField(11)
  final String? description;

  @HiveField(12)
  final bool isAnniversary;

  @HiveField(13)
  final bool isImportant;

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
    this.repeatType = 'NONE',
    this.alarmOffsetMinutes,
    this.description,
    this.isAnniversary = false,
    this.isImportant = false,
  });
}
