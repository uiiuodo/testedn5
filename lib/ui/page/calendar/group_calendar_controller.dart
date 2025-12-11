import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';

import '../../../../data/model/person.dart';
import '../../../../service/anniversary_service.dart';

import '../../../../data/repository/schedule_repository.dart';
import '../../../../data/repository/person_repository.dart';
import '../home/home_controller.dart';
import '../../../../data/repository/planned_task_repository.dart';
import '../../../../data/model/planned_task.dart';

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

  final RxList<PlannedTask> plannedTasks = <PlannedTask>[].obs;

  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final PlannedTaskRepository _plannedTaskRepository = PlannedTaskRepository();
  final PersonRepository _personRepository = PersonRepository();

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
    fetchPeople();
    fetchPlannedTasks();
  }

  void fetchPlannedTasks() {
    plannedTasks.value = _plannedTaskRepository.getTasksByGroup(
      selectedGroupId.value,
    );
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

  void selectGroup(String groupId) {
    selectedGroupId.value = groupId;
    fetchPlannedTasks(); // Reload planned tasks for new group
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
    List<Person> allPeople = [];
    try {
      if (Get.isRegistered<HomeController>()) {
        allPeople = Get.find<HomeController>().people;
      } else {
        allPeople = people;
      }
    } catch (e) {
      allPeople = people;
    }

    final filteredPeople = selectedGroupId.value == 'all'
        ? allPeople
        : allPeople.where((p) => p.groupId == selectedGroupId.value).toList();

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
              ),
            );
          }
        }
      }
    }

    // Anniversaries via Service
    items.addAll(
      AnniversaryService.getAnniversariesForDay(
        filteredPeople,
        day,
        usePersonNamePrefix: true,
      ),
    );

    // Sort: Anniversary (0) > Care (1) > Etc (2)
    // Birthdays are Anniversary type, so they come first.
    items.sort((a, b) {
      return a.type.index.compareTo(b.type.index);
    });

    return items;
  }

  Future<void> addPlannedTask(String content) async {
    final newTask = PlannedTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
      groupId: selectedGroupId.value == 'all' ? null : selectedGroupId.value,
    );
    await _plannedTaskRepository.addTask(newTask);
    fetchPlannedTasks();
  }

  Future<void> updatePlannedTask(PlannedTask task, String newContent) async {
    final updatedTask = task.copyWith(content: newContent);
    await _plannedTaskRepository.updateTask(updatedTask);
    fetchPlannedTasks();
  }

  Future<void> deletePlannedTask(String id) async {
    await _plannedTaskRepository.deleteTask(id);
    fetchPlannedTasks();
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
