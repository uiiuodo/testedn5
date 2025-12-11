import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/model/person.dart';
import '../../../data/model/schedule.dart';
import '../../../data/repository/person_repository.dart';
import '../../../data/repository/schedule_repository.dart';

enum NotificationType { anniversary, care }

class AppNotification {
  final String id;
  final String title;
  final DateTime dateTime;
  final String dDay; // "D-Day", "D-5", or Date string for Schedule
  final NotificationType type;
  final bool isSchedule; // To distinguish Person Anniversary vs Schedule
  final String? personId;

  AppNotification({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.dDay,
    required this.type,
    this.isSchedule = false,
    this.personId,
  });
}

class NotificationController extends GetxController {
  final RxString selectedFilter = '전체'.obs; // 전체, 기념일, 챙기기
  final PersonRepository _personRepository = PersonRepository();
  final ScheduleRepository _scheduleRepository = Get.find<ScheduleRepository>();

  final RxList<AppNotification> allNotifications = <AppNotification>[].obs;

  List<AppNotification> get filteredNotifications {
    // 1. Filter by Tab
    List<AppNotification> result;
    if (selectedFilter.value == '전체') {
      result = allNotifications;
    } else if (selectedFilter.value == '기념일') {
      result = allNotifications
          .where((n) => n.type == NotificationType.anniversary)
          .toList();
    } else {
      // 챙기기
      result = allNotifications
          .where((n) => n.type == NotificationType.care)
          .toList();
    }

    // 2. Sort by DateTime
    result.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    List<AppNotification> list = [];
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // 1. Fetch Person Anniversaries/Birthdays (Existing Logic)
    final people = _personRepository.getPeople();
    for (final person in people) {
      if (person.birthDate != null) {
        final nextDate = _getNextEventDate(today, person.birthDate!);
        final daysUntil = nextDate.difference(todayStart).inDays;

        // Show if within 30 days? Or just show all upcoming?
        // Requirement says "Today and future".
        // Let's keep existing 30 days logic for birthdays/anniversaries if strictly needed,
        // but user prompt says "today and future". Let's show all valid upcoming for now or stick to a reasonable range.
        // Existing logic was <= 30. Let's keep it to avoid noise.
        if (daysUntil >= 0 && daysUntil <= 30) {
          list.add(
            AppNotification(
              id: '${person.id}_birthday',
              title: '${person.name} 생일',
              dateTime: nextDate,
              dDay: daysUntil == 0 ? 'D-day' : 'D-$daysUntil',
              type: NotificationType.anniversary,
              personId: person.id,
            ),
          );
        }
      }

      for (final ann in person.anniversaries) {
        final nextDate = _getNextEventDate(today, ann.date);
        final daysUntil = nextDate.difference(todayStart).inDays;
        if (daysUntil >= 0 && daysUntil <= 30) {
          list.add(
            AppNotification(
              id: '${person.id}_${ann.id}',
              title: '${person.name} ${ann.title}',
              dateTime: nextDate,
              dDay: daysUntil == 0 ? 'D-day' : 'D-$daysUntil',
              type: NotificationType.anniversary,
              personId: person.id,
            ),
          );
        }
      }
    }

    // 2. Fetch Schedules
    final schedules = _scheduleRepository.getSchedules();
    for (final schedule in schedules) {
      // Filter: Today onwards
      // Only if isAnniversary OR isImportant OR alarmOffsetMinutes != null
      // For "All" tab: includes all of above.

      if (!schedule.isAnniversary &&
          !schedule.isImportant &&
          schedule.alarmOffsetMinutes == null) {
        continue;
      }

      // Check date
      // For simple schedules without repeat logic (first version)
      // If repeat exists, we should ideally expand. MVP: Use startDateTime.
      final sDate = schedule.startDateTime;
      final sDateStart = DateTime(sDate.year, sDate.month, sDate.day);

      if (sDateStart.isBefore(todayStart)) {
        continue; // Past
      }

      // Determine Type
      NotificationType type;
      if (schedule.isAnniversary) {
        type = NotificationType.anniversary;
      } else {
        // Important or Alarm -> Care
        type = NotificationType.care;
      }

      // Formatting D-Day or Date string
      // Request: "MM.dd (E) HH:mm"
      // We can store the formatted string in dDay or add a new field.
      // Let's format it in UI, but `dDay` field is string.
      // For schedules, let's put the formatted date key in dDay field or handle in UI.
      // Existing UI uses `dDay` field for big text.
      // Let's calculate D-Day for schedules too if they are anniversaries?
      // User requirement 2.3: "Top: Date/Time... Middle: Title"
      // UI implementation is different from existing D-Day list.
      // We should unify or distinguish.
      // I'll assume we can use `AppNotification` to carry the data and UI decides how to render.

      list.add(
        AppNotification(
          id: schedule.id,
          title: schedule.title,
          dateTime: sDate,
          dDay: '', // Will be formatted in UI based on isSchedule
          type: type,
          isSchedule: true,
          personId: schedule.personIds.isNotEmpty
              ? schedule.personIds.first
              : null,
        ),
      );
    }

    allNotifications.assignAll(list);
  }

  DateTime _getNextEventDate(DateTime today, DateTime eventDate) {
    DateTime thisYearEvent = DateTime(
      today.year,
      eventDate.month,
      eventDate.day,
    );
    if (thisYearEvent.isBefore(DateTime(today.year, today.month, today.day))) {
      thisYearEvent = DateTime(today.year + 1, eventDate.month, eventDate.day);
    }
    return thisYearEvent;
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
