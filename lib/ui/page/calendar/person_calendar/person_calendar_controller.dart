import 'package:get/get.dart';
import '../../../../data/model/schedule.dart'; // Assuming Schedule model exists or will be created
// Assuming Repository exists

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

  PersonCalendarController({required this.personId});

  @override
  void onInit() {
    super.onInit();
    // Set initial date to 2025 Nov for demo purposes as per HTML
    focusedDay.value = DateTime(2025, 11, 1);
    selectedDay.value = DateTime(2025, 11, 1);
    fetchSchedules();
  }

  void fetchSchedules() {
    // ... (existing fetch logic) ...
    // Dummy data matching the HTML design + Planned Schedules
    final allDummySchedules = [
      // ... (existing dummy data) ...
      Schedule(
        id: '1',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 1),
        endDateTime: DateTime(2025, 11, 1),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '2',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 2),
        endDateTime: DateTime(2025, 11, 2),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '3',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 9),
        endDateTime: DateTime(2025, 11, 9),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '4',
        title: '저녁식사',
        startDateTime: DateTime(2025, 11, 12),
        endDateTime: DateTime(2025, 11, 12),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '5',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 15),
        endDateTime: DateTime(2025, 11, 15),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '6',
        title: '전시회',
        startDateTime: DateTime(2025, 11, 16),
        endDateTime: DateTime(2025, 11, 16),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '7',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 22),
        endDateTime: DateTime(2025, 11, 22),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '8',
        title: '출장',
        startDateTime: DateTime(2025, 11, 23),
        endDateTime: DateTime(2025, 11, 25),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      Schedule(
        id: '9',
        title: '데이트',
        startDateTime: DateTime(2025, 11, 29),
        endDateTime: DateTime(2025, 11, 29),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
      ),
      // Planned Schedules
      Schedule(
        id: '101',
        title: '26년 1월 신년맞이 등산계획 (미정)\n> 이도, 인선, 경하',
        startDateTime: DateTime(2026, 1, 1),
        endDateTime: DateTime(2026, 1, 1),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
        isPlanned: true,
      ),
      Schedule(
        id: '102',
        title: '26년 3월 27~29일\n상하이 여행 예정',
        startDateTime: DateTime(2026, 3, 27),
        endDateTime: DateTime(2026, 3, 29),
        allDay: true,
        type: ScheduleType.etc,
        personIds: [personId],
        isPlanned: true,
      ),
      Schedule(
        id: '103',
        title: '26년 5월 10일 오후 8시\n이도가 좋아하는 이치코 아오바 내한 공연 예매',
        startDateTime: DateTime(2026, 5, 10, 20),
        endDateTime: DateTime(2026, 5, 10, 22),
        allDay: false,
        type: ScheduleType.etc,
        personIds: [personId],
        isPlanned: true,
      ),
    ];

    schedules.value = allDummySchedules.where((s) => !s.isPlanned).toList();
    plannedSchedules.value = allDummySchedules
        .where((s) => s.isPlanned)
        .toList();
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  void addSchedule(Schedule schedule) {
    // TODO: Call repository to add
    if (schedule.isPlanned) {
      plannedSchedules.add(schedule);
    } else {
      schedules.add(schedule);
    }
  }

  void updateSchedule(Schedule schedule) {
    // TODO: Call repository to update
    if (schedule.isPlanned) {
      final index = plannedSchedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        plannedSchedules[index] = schedule;
      }
    } else {
      final index = schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        schedules[index] = schedule;
      }
    }
    schedules.refresh();
    plannedSchedules.refresh();
  }

  void deleteSchedule(String scheduleId, {bool isPlanned = false}) {
    // TODO: Call repository to delete
    if (isPlanned) {
      plannedSchedules.removeWhere((s) => s.id == scheduleId);
    } else {
      schedules.removeWhere((s) => s.id == scheduleId);
    }
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
