import 'package:get/get.dart';
import '../../../../data/model/schedule.dart';
import '../../../../data/repository/schedule_repository.dart';

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

  List<Schedule> getEventsForDay(DateTime day) {
    return schedules.where((s) => isSameDay(s.startDateTime, day)).toList();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
