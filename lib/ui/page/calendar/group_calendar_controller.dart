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

  List<Schedule> getDayItems(DateTime day) {
    List<Schedule> items = [];

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

    items.addAll(eventsForDay);

    // 2. Birthdays & Anniversaries
    final filteredPeople = selectedGroupId.value == 'all'
        ? people
        : people.where((p) => p.groupId == selectedGroupId.value).toList();

    for (final person in filteredPeople) {
      // Birthdays
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
            // Create a synthetic Schedule for birthday
            items.add(
              Schedule(
                id: 'birthday_${person.id}_${day.millisecondsSinceEpoch}',
                title: '🎂 ${person.name}',
                startDateTime: day,
                endDateTime: day,
                allDay: true,
                type: ScheduleType.anniversary,
                personIds: [person.id],
                groupId: person.groupId,
                isAnniversary: true,
                // Other required fields
              ),
            );
          }
        }
      }

      // Anniversaries
      for (final anniv in person.anniversaries) {
        if (anniv.date.month == day.month && anniv.date.day == day.day) {
          items.add(
            Schedule(
              id: 'anniv_${anniv.id}_${day.year}',
              title: '${person.name} - ${anniv.title}',
              startDateTime: day,
              endDateTime: day,
              allDay: true,
              type: ScheduleType.anniversary,
              personIds: [person.id],
              groupId: null, // Gray color for anniversaries
              isAnniversary: true,
              // Other required fields
            ),
          );
        }
      }
    }

    // Sort: Anniversary (0) > Care (1) > Etc (2)
    // Birthdays are Anniversary type, so they come first.
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
      // print('Error adding group: $e');
    }
  }
}
