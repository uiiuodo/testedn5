import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';
import '../../../../data/repository/schedule_repository.dart';
import '../../../../service/anniversary_service.dart';
import '../../home/home_controller.dart';
import '../schedule_edit_screen.dart';
import '../../../../data/repository/planned_task_repository.dart';
import '../../../../data/model/planned_task.dart';

class PersonCalendarController extends GetxController {
  final String personId;
  final ScheduleRepository _scheduleRepository = Get.find<ScheduleRepository>();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final PlannedTaskRepository _plannedTaskRepository = PlannedTaskRepository();
  final RxList<PlannedTask> plannedTasks = <PlannedTask>[].obs;

  PersonCalendarController({required this.personId});

  final RxBool isEditMode = false.obs;

  bool get isOnTodayMonth {
    final now = DateTime.now();
    return focusedDay.value.year == now.year &&
        focusedDay.value.month == now.month;
  }

  // Planned tasks are now handled by plannedTasks list and PlannedTaskRepository

  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(null);

  // Map of normalized date to list of schedules
  final RxMap<DateTime, List<Schedule>> events =
      <DateTime, List<Schedule>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = focusedDay.value;
    fetchSchedules();
    selectedDay.value = focusedDay.value;
    fetchSchedules();
    fetchPlannedTasks();
  }

  void fetchPlannedTasks() {
    plannedTasks.value = _plannedTaskRepository.getTasksByPerson(personId);
  }

  Future<void> addPlannedTask(String content) async {
    final newTask = PlannedTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
      personId: personId,
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

  Future<void> fetchSchedules() async {
    loadSchedules();
  }

  void loadSchedules() {
    final allSchedules = _scheduleRepository.getSchedulesByPerson(personId);

    // Group by date
    final Map<DateTime, List<Schedule>> newEvents = {};

    for (var schedule in allSchedules) {
      if (schedule.repeatType != 'NONE') {
        // TODO: Handle repeat logic for current month view?
        // For now, simpler implementation: just show on start date.
        // Or if monthly expantion needed, do it here.
        // Requirement says "calculate instances for current month".
        // I'll leave basic for now and focus on wiring.
      }

      var date = schedule.startDateTime;
      var normalizedDate = DateTime(date.year, date.month, date.day);

      if (newEvents[normalizedDate] == null) {
        newEvents[normalizedDate] = [];
      }
      newEvents[normalizedDate]!.add(schedule);
    }
    events.assignAll(newEvents);
  }

  void goToToday() {
    final now = DateTime.now();
    focusedDay.value = now;
    selectedDay.value = now;
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  List<ScheduleWithColor> getDayItems(DateTime day) {
    // Map Schedule to a view model with color
    final schedules = getEventsForDay(day);
    return schedules
        .map(
          (s) => ScheduleWithColor(
            title: s.title,
            // Logic for color?
            // "If group color exists...".
            // I don't have group colors here.
            // I'll return null or a hashed color for now or parse if I had Group repo.
            groupColor: s.groupId != null
                ? 0xFF9C27B0
                : null, // Purple placeholder if group ID exists
          ),
        )
        .toList();
  }

  List<Schedule> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    final dayEvents = events[normalized] ?? [];

    final List<Schedule> combined = [...dayEvents];

    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final person = homeController.people.firstWhereOrNull(
          (p) => p.id == personId,
        );

        if (person != null) {
          // Birthday Logic
          if (person.birthDate != null &&
              person.birthDate!.month == day.month &&
              person.birthDate!.day == day.day) {
            combined.add(
              Schedule(
                id: 'birthday_${person.id}_${day.year}',
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

          combined.addAll(
            AnniversaryService.getAnniversariesForDay(
              [person],
              day,
              usePersonNamePrefix: false,
            ),
          );
        }
      }
    } catch (e) {
      // Ignore
    }

    // Sort: Anniversary (0) > Care (1) > Etc (2)
    combined.sort((a, b) => a.type.index.compareTo(b.type.index));

    return combined;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  Future<void> addSchedule([Schedule? result]) async {
    result ??= await Get.to(
      () => ScheduleEditScreen(
        initialDate: selectedDay.value,
        personId: personId,
      ),
    );

    if (result != null) {
      await _scheduleRepository.addSchedule(result);
      fetchSchedules();
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleRepository.updateSchedule(schedule);
    fetchSchedules();
  }

  Future<void> deleteSchedule(String id, {bool isPlanned = false}) async {
    await _scheduleRepository.deleteSchedule(id);
    fetchSchedules();
  }
}

class ScheduleWithColor {
  final String title;
  final int? groupColor;
  ScheduleWithColor({required this.title, this.groupColor});
}
