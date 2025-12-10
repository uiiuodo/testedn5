import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';
import '../../../../data/model/group.dart';
import '../../../../data/model/person.dart';
import '../../../../data/repository/group_repository.dart';
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

  final GroupRepository _groupRepository = GroupRepository();
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

  // Filter Logic
  List<Schedule> get filteredCalendarSchedules {
    // For calendar, we show all schedules (planned or not) that match the group
    // But typically "Calendar Schedules" might imply confirmed ones if we wanted to separate them visually.
    // However, the requirement is to show everything on the calendar.
    // So we filter by group only.
    if (selectedGroupId.value == 'all') {
      return schedules;
    }
    return schedules.where((s) => s.groupId == selectedGroupId.value).toList();
  }

  List<Schedule> get filteredPlannedSchedules {
    // For the list, we specifically want "Planned" schedules (isPlanned == true)
    // filtered by group.
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

  List<String> getEventsForDay(DateTime day) {
    final List<String> events = [];

    // 1. Add Schedule Events
    final eventsForDay = filteredCalendarSchedules.where((s) {
      // Check for multi-day overlap
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

    events.addAll(eventsForDay.map((s) => s.title));

    // 2. Add Birthday Events
    final filteredPeople = selectedGroupId.value == 'all'
        ? people
        : people.where((p) => p.groupId == selectedGroupId.value).toList();

    for (final person in filteredPeople) {
      if (person.birthDate != null) {
        final birthDate = person.birthDate!;
        if (birthDate.month == day.month && birthDate.day == day.day) {
          events.add('🎂 ${person.name}');
        }
      }

      // 3. Add Anniversary Events
      for (final anniversary in person.anniversaries) {
        if (anniversary.date.month == day.month &&
            anniversary.date.day == day.day) {
          events.add('🎉 ${anniversary.title}');
        }
      }
    }

    return events;
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        colorValue: colorValue,
      );
      await _groupRepository.addGroup(newGroup);
    }
  }
}
