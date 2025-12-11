import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';

import '../../../../data/model/person.dart';

import '../../../../data/repository/schedule_repository.dart';
import '../../../../data/repository/person_repository.dart';
import '../home/home_controller.dart';

class GroupCalendarController extends GetxController {
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(null);
  final RxBool isEditMode = false.obs;

  // Filter State
  final RxString selectedGroupId = 'all'.obs;

  // Schedules - Unified List
  final RxList<Schedule> schedules = <Schedule>[].obs;

  // People - For Birthdays
  final RxList<Person> people = <Person>[].obs;

  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final PersonRepository _personRepository = PersonRepository();

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
    fetchPeople();
  }

  Future<void> fetchSchedules() async {
    schedules.value = _scheduleRepository.getSchedules();
  }

  void fetchPeople() {
    people.value = _personRepository.getPeople();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Filter Logic
  List<Schedule> get filteredCalendarSchedules {
    if (selectedGroupId.value == 'all') {
      return schedules;
    }
    return schedules.where((s) => s.groupId == selectedGroupId.value).toList();
  }

  List<Schedule> get filteredPlannedSchedules {
    final planned = schedules.where((s) => s.isPlanned).toList();

    if (selectedGroupId.value == 'all') {
      return planned;
    }
    return planned.where((s) => s.groupId == selectedGroupId.value).toList();
  }

  void selectGroup(String groupId) {
    selectedGroupId.value = groupId;
    update();
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  List<CalendarDayItem> getDayItems(DateTime day) {
    final List<CalendarDayItem> items = [];

    // 1. Schedules
    final eventsForDay = filteredCalendarSchedules.where((s) {
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
      int? colorValue;
      // Find group color if available
      if (s.groupId != null) {
        final group = Get.find<HomeController>().groups.firstWhereOrNull(
          (g) => g.id == s.groupId,
        );
        colorValue = group?.colorValue;
      } else if (s.personIds.isNotEmpty) {
        // Fallback to first person's group
        final person = people.firstWhereOrNull(
          (p) => p.id == s.personIds.first,
        );
        if (person != null && person.groupId != null) {
          final group = Get.find<HomeController>().groups.firstWhereOrNull(
            (g) => g.id == person.groupId,
          );
          colorValue = group?.colorValue;
        }
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
    final filteredPeople = selectedGroupId.value == 'all'
        ? people
        : people.where((p) => p.groupId == selectedGroupId.value).toList();

    for (final person in filteredPeople) {
      if (person.birthDate != null) {
        final birthDate = person.birthDate!;
        if (birthDate.month == day.month && birthDate.day == day.day) {
          // Check for duplicate explicit schedule
          final hasSchedule = filteredCalendarSchedules.any(
            (s) =>
                s.personIds.contains(person.id) &&
                s.type == ScheduleType.anniversary &&
                isSameDay(s.startDateTime, day),
          );

          if (!hasSchedule) {
            int? colorValue;
            if (person.groupId != null) {
              final group = Get.find<HomeController>().groups.firstWhereOrNull(
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

    // Sort: Birthday > Anniversary > Schedule
    items.sort((a, b) {
      return a.type.index.compareTo(b.type.index);
    });

    return items;
  }

  Future<void> deletePlannedSchedule(String id) async {
    await _scheduleRepository.deleteSchedule(id);
    fetchSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleRepository.updateSchedule(schedule);
    fetchSchedules();
  }

  Future<void> addSchedule(Schedule schedule) async {
    // Assign current group if selected and not 'all'
    if (selectedGroupId.value != 'all' && schedule.groupId == null) {
      // We can't easily modify the immutable Schedule here without copyWith.
      // But let's assume the user selects the group in the edit screen or we handle it there.
      // For now, if we need to force the group ID:
      // schedule = schedule.copyWith(groupId: selectedGroupId.value); // If copyWith existed
    }

    // If the schedule doesn't have a group ID and we are in 'all', it might be unassigned.
    // But let's just save it.

    await _scheduleRepository.addSchedule(schedule);
    fetchSchedules();
  }

  void addGroup(String name, int colorValue) async {
    try {
      final homeController = Get.find<HomeController>();
      homeController.addGroup(name, colorValue);
    } catch (e) {
      print('Error adding group: $e');
    }
  }
}

enum CalendarItemType { birthday, anniversary, schedule }

class CalendarDayItem {
  final String title;
  final int? groupColor;
  final CalendarItemType type;

  CalendarDayItem({required this.title, required this.type, this.groupColor});
}
