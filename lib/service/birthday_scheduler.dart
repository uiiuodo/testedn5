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
}
