import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';
import '../../../../data/repository/schedule_repository.dart';
import '../../home/home_controller.dart';

class PersonCalendarController extends GetxController {
  final String personId;

  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(null);
  final RxBool isEditMode = false.obs; // Renamed to isEditMode as per request
  final RxList<Schedule> schedules = <Schedule>[].obs;
  final RxList<Schedule> plannedSchedules = <Schedule>[].obs;

  final DateTime today = DateTime.now();

  bool get isOnTodayMonth {
    return focusedDay.value.year == today.year &&
        focusedDay.value.month == today.month;
  }

  final ScheduleRepository _scheduleRepository = Get.find<ScheduleRepository>();

  PersonCalendarController({required this.personId});

  @override
  void onInit() {
    super.onInit();
    // Set initial date to 2025 Nov for demo purposes as per HTML
    focusedDay.value = DateTime(2025, 11, 1);
    selectedDay.value = DateTime(2025, 11, 1);
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    final allSchedules = _scheduleRepository.getSchedules();
    final personSchedules = allSchedules
        .where((s) => s.personIds.contains(personId))
        .toList();

    schedules.value = personSchedules.where((s) => !s.isPlanned).toList();
    plannedSchedules.value = personSchedules.where((s) => s.isPlanned).toList();
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _scheduleRepository.addSchedule(schedule);
    await fetchSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleRepository.updateSchedule(schedule);
    await fetchSchedules();
  }

  Future<void> deleteSchedule(
    String scheduleId, {
    bool isPlanned = false,
  }) async {
    await _scheduleRepository.deleteSchedule(scheduleId);
    await fetchSchedules();
  }

  void goToToday() {
    focusedDay.value = today;
    selectedDay.value = today;
    update();
  }

  void returnToToday() {
    goToToday();
  }

  List<CalendarDayItem> getDayItems(DateTime day) {
    final List<CalendarDayItem> items = [];

    // 1. Schedules
    final eventsForDay = schedules.where((s) {
      if (s.allDay || !isSameDay(s.startDateTime, s.endDateTime)) {
        final start = DateTime(
          s.startDateTime.year,
          s.startDateTime.month,
          s.startDateTime.day,
        );
        final end = DateTime(
          s.endDateTime.year,
          s.endDateTime.month,
          s.endDateTime.day,
        );
        final check = DateTime(day.year, day.month, day.day);
        return (check.isAtSameMomentAs(start) || check.isAfter(start)) &&
            (check.isAtSameMomentAs(end) || check.isBefore(end));
      }
      return isSameDay(s.startDateTime, day);
    }).toList();

    for (var s in eventsForDay) {
      // For PersonCalendar, we might want to show the person's group color or the schedule's group color.
      // Since it's a person calendar, usually we show that person's group color.
      // But if the schedule has a specific group, we use that.

      // However, we don't have easy access to HomeController here to get groups list without putting it.
      // Let's try to get it from HomeController if available.
      int? colorValue;
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          if (s.groupId != null) {
            final group = homeController.groups.firstWhereOrNull(
              (g) => g.id == s.groupId,
            );
            colorValue = group?.colorValue;
          } else {
            // Fallback to person's group
            // We need to fetch person to know their group.
            // We can fetch person from PersonRepository or HomeController.
            final person = homeController.people.firstWhereOrNull(
              (p) => p.id == personId,
            );
            if (person != null && person.groupId != null) {
              final group = homeController.groups.firstWhereOrNull(
                (g) => g.id == person.groupId,
              );
              colorValue = group?.colorValue;
            }
          }
        }
      } catch (e) {
        // Ignore
      }

      items.add(
        CalendarDayItem(
          title: s.title,
          type: s.type == ScheduleType.anniversary
              ? CalendarItemType.anniversary
              : CalendarItemType.schedule,
          groupColor: colorValue,
        ),
      );
    }

    // 2. Birthdays
    // Check if it's this person's birthday
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final person = homeController.people.firstWhereOrNull(
          (p) => p.id == personId,
        );
        if (person != null && person.birthDate != null) {
          final birthDate = person.birthDate!;
          if (birthDate.month == day.month && birthDate.day == day.day) {
            // Check for duplicate
            final hasSchedule = schedules.any(
              (s) =>
                  s.type == ScheduleType.anniversary &&
                  isSameDay(s.startDateTime, day),
            );

            if (!hasSchedule) {
              int? colorValue;
              if (person.groupId != null) {
                final group = homeController.groups.firstWhereOrNull(
                  (g) => g.id == person.groupId,
                );
                colorValue = group?.colorValue;
              }
              items.add(
                CalendarDayItem(
                  title: '🎂 ${person.name}',
                  type: CalendarItemType.birthday,
                  groupColor: colorValue,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      // Ignore
    }

    // Sort
    items.sort((a, b) {
      return a.type.index.compareTo(b.type.index);
    });

    return items;
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

enum CalendarItemType { birthday, anniversary, schedule }

class CalendarDayItem {
  final String title;
  final int? groupColor;
  final CalendarItemType type;

  CalendarDayItem({required this.title, required this.type, this.groupColor});
}
