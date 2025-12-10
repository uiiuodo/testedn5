import 'package:get/get.dart';
import '../data/model/person.dart';
import '../data/model/schedule.dart';
import '../data/repository/schedule_repository.dart';
import '../ui/page/notification/notification_controller.dart';

class BirthdayScheduler {
  static final ScheduleRepository _scheduleRepository = ScheduleRepository();

  static Future<void> scheduleBirthday(Person person) async {
    if (person.birthDate == null) return;

    final birthDate = person.birthDate!;
    final now = DateTime.now();

    // Calculate next birthday (this year or next year)
    // We want the birthday that is upcoming or today.
    DateTime thisYearBirthday = DateTime(
      now.year,
      birthDate.month,
      birthDate.day,
    );
    DateTime nextBirthday;

    if (thisYearBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
      // Birthday has passed this year, schedule for next year
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    } else {
      // Birthday is today or later this year
      nextBirthday = thisYearBirthday;
    }

    // Create Schedule
    // ID: {personId}_birthday
    final scheduleId = '${person.id}_birthday';
    final schedule = Schedule(
      id: scheduleId,
      title: '${person.name} 생일',
      startDateTime: nextBirthday,
      endDateTime: nextBirthday,
      allDay: true,
      type: ScheduleType.anniversary,
      personIds: [person.id],
      groupId: person.groupId,
      isPlanned: false,
    );

    // Save to Repository
    await _scheduleRepository.updateSchedule(schedule);

    // Refresh NotificationController if alive
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchUpcomingEvents();
    }
  }

  static Future<void> scheduleAnniversaries(Person person) async {
    // 1. Get all schedules
    final allSchedules = _scheduleRepository.getSchedules();

    // 2. Find existing anniversary schedules for this person
    // We assume ID format: {personId}_anniv_{annivId}
    final personAnnivSchedules = allSchedules.where(
      (s) =>
          s.id.startsWith('${person.id}_anniv_') &&
          s.type == ScheduleType.anniversary,
    );

    // 3. Delete them
    for (final schedule in personAnnivSchedules) {
      await _scheduleRepository.deleteSchedule(schedule.id);
    }

    // 4. Create new schedules
    final now = DateTime.now();
    for (final anniv in person.anniversaries) {
      // Calculate next occurrence
      DateTime baseDate = anniv.date;
      DateTime thisYearDate = DateTime(now.year, baseDate.month, baseDate.day);
      DateTime nextDate;

      if (thisYearDate.isBefore(DateTime(now.year, now.month, now.day))) {
        nextDate = DateTime(now.year + 1, baseDate.month, baseDate.day);
      } else {
        nextDate = thisYearDate;
      }

      final scheduleId = '${person.id}_anniv_${anniv.id}';
      final schedule = Schedule(
        id: scheduleId,
        title: anniv.title,
        startDateTime: nextDate,
        endDateTime: nextDate,
        allDay: true,
        type: ScheduleType.anniversary,
        personIds: [person.id],
        groupId: person.groupId,
        isPlanned: false,
      );

      await _scheduleRepository.updateSchedule(schedule);
    }

    // Refresh NotificationController if alive
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchUpcomingEvents();
    }
  }
}
