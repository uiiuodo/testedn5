import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:table_calendar/table_calendar.dart';
import 'person_calendar_controller.dart';
import '../../../../data/model/schedule.dart';
import '../schedule_edit_screen.dart';
import '../../../widgets/common/refreshable_layout.dart';

class PersonCalendarScreen extends GetView<PersonCalendarController> {
  const PersonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshableLayout(
                onRefresh: () async {
                  await controller.fetchSchedules();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Header: Back Icon, Edit Icon, Year/Month
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Back Button & Return to Today
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(() {
                                  if (controller.isOnTodayMonth) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    onTap: controller.goToToday,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.arrow_back,
                                            size: 12,
                                            color: Color(0xFF565656),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '현재 날짜로 돌아가기',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF565656),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),

                            // Right: Edit Icon + Year + Month
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Edit Icon (Pen)
                                Obx(
                                  () => GestureDetector(
                                    onTap: controller.toggleEditMode,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: controller.isEditMode.value
                                            ? Colors.black.withOpacity(0.1)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        controller.isEditMode.value
                                            ? Icons.edit
                                            : Icons.edit_outlined,
                                        size: 20,
                                        color: controller.isEditMode.value
                                            ? Colors
                                                  .black // Changed to black to match Group Calendar
                                            : const Color(0xFF979797),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Year (e.g., 2025)
                                Obx(
                                  () => Text(
                                    '${controller.focusedDay.value.year}',
                                    style: const TextStyle(
                                      color: Color(0xFF979797),
                                      fontSize: 15,
                                      fontFamily: 'Noto Sans',
                                      fontWeight: FontWeight.w500,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                // Month (e.g., 11)
                                Obx(
                                  () => Text(
                                    '${controller.focusedDay.value.month}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontFamily: 'Noto Sans',
                                      fontWeight: FontWeight.w500,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Calendar
                      Obx(
                        () => TableCalendar<Schedule>(
                          firstDay: DateTime(2020, 1, 1),
                          lastDay: DateTime(2030, 12, 31),
                          focusedDay: controller.focusedDay.value,
                          selectedDayPredicate: (day) =>
                              isSameDay(controller.selectedDay.value, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            controller.selectedDay.value = selectedDay;
                            controller.focusedDay.value = focusedDay;
                          },
                          eventLoader: controller.getEventsForDay,
                          headerVisible: false,
                          daysOfWeekHeight: 20,
                          rowHeight: 60,
                          calendarFormat: CalendarFormat.month,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Color(0xFF4A4A4A),
                              fontSize: 8,
                              fontFamily: 'Noto Sans',
                              fontWeight: FontWeight.w300,
                            ),
                            weekendStyle: TextStyle(
                              color: Color(0xFF0084FF),
                              fontSize: 8,
                              fontFamily: 'Noto Sans',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            dowBuilder: (context, day) {
                              if (day.weekday == DateTime.sunday) {
                                return const Center(
                                  child: Text(
                                    'Sun',
                                    style: TextStyle(
                                      color: Color(0xFFFF0000),
                                      fontSize: 8,
                                      fontFamily: 'Noto Sans',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                            defaultBuilder: (context, day, focusedDay) {
                              return _buildDayCell(
                                context,
                                day,
                                controller.getEventsForDay(day),
                              );
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              return _buildDayCell(
                                context,
                                day,
                                controller.getEventsForDay(day),
                                isSelected: true,
                              );
                            },
                            todayBuilder: (context, day, focusedDay) {
                              return _buildDayCell(
                                context,
                                day,
                                controller.getEventsForDay(day),
                                isToday: true,
                              );
                            },
                            outsideBuilder: (context, day, focusedDay) {
                              return const SizedBox.shrink();
                            },
                            markerBuilder: (context, day, events) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Add Schedule Button (Only for Planned Schedules as per request)
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Get.bottomSheet(
                              ScheduleEditScreen(
                                initialDate:
                                    controller.selectedDay.value ??
                                    DateTime.now(),
                                isPlanned: true,
                                personId: controller.personId,
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                            if (result != null && result is Schedule) {
                              await controller.addSchedule(result);
                            } else {
                              await controller.fetchSchedules();
                            }
                          },
                          child: Container(
                            width: 291,
                            height: 41,
                            decoration: BoxDecoration(
                              color: const Color(0xFF414141),
                              borderRadius: BorderRadius.circular(20.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 10,
                                    color: Color(0xFF414141),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '이 사람과의 일정 추가하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Noto Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Planned Schedules List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  color: const Color(0xFFB0B0B0),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '계획해야 하는 일정',
                                  style: TextStyle(
                                    color: Color(0xFF9D9D9D),
                                    fontSize: 10,
                                    fontFamily: 'Noto Sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              () => Column(
                                children: controller.plannedSchedules.map((
                                  schedule,
                                ) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                schedule.title,
                                                style: const TextStyle(
                                                  color: Color(0xFF464646),
                                                  fontSize: 10,
                                                  fontFamily: 'Noto Sans',
                                                  fontWeight: FontWeight.w300,
                                                  height: 1.5,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (controller.isEditMode.value)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  // Edit
                                                  final result =
                                                      await Get.bottomSheet(
                                                        ScheduleEditScreen(
                                                          schedule: schedule,
                                                          isPlanned: true,
                                                          personId: controller
                                                              .personId,
                                                        ),
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                      );
                                                  if (result != null &&
                                                      result is Schedule) {
                                                    await controller
                                                        .updateSchedule(result);
                                                  } else {
                                                    await controller
                                                        .fetchSchedules();
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 16,
                                                    color: Color(0xFF9D9D9D),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  // Delete
                                                  Get.dialog(
                                                    AlertDialog(
                                                      title: const Text(
                                                        '일정 삭제',
                                                      ),
                                                      content: const Text(
                                                        '이 일정을 삭제하시겠습니까?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          child: const Text(
                                                            '취소',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            controller
                                                                .deleteSchedule(
                                                                  schedule.id,
                                                                  isPlanned:
                                                                      true,
                                                                );
                                                            Get.back();
                                                          },
                                                          child: const Text(
                                                            '삭제',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: 16,
                                                    color: Color(0xFF9D9D9D),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, -4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  currentIndex: 1, // Calendar tab
                  onTap: (index) {
                    if (index == 0)
                      Get.back(); // Go back to home if Home tapped
                  },
                  selectedItemColor: const Color(0xFF404040),
                  unselectedItemColor: const Color(0xFFDDDDDD),
                  selectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: '홈',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: '캘린더',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: '마이페이지',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    List<Schedule> events, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    // Check for multi-day events
    bool isMultiDayStart = false;
    bool isMultiDayMiddle = false;
    bool isMultiDayEnd = false;
    Schedule? multiDayEvent;
    bool hasEvents = events.isNotEmpty;

    for (var event in events) {
      if (event.title == '출장') {
        multiDayEvent = event;
        if (isSameDay(event.startDateTime, day))
          isMultiDayStart = true;
        else if (isSameDay(event.endDateTime, day))
          isMultiDayEnd = true;
        else
          isMultiDayMiddle = true;
      }
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Gray background box for days with events
        if (hasEvents)
          Positioned(
            top: 0,
            child: Container(
              width: 36,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5).withOpacity(0.64),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

        // Content
        Container(
          margin: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              // Render events
              ...events
                  .where((e) => e.title != '출장')
                  .take(3)
                  .map((event) => _buildEventMarker(event)),

              // Render multi-day event bar if exists
              if (multiDayEvent != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: _buildMultiDayBar(
                    multiDayEvent,
                    isMultiDayStart,
                    isMultiDayMiddle,
                    isMultiDayEnd,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventMarker(Schedule event) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
        horizontal: 2.0,
      ), // Adjusted padding to fit inside 36px width better
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Container(
            width: 1,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD8FD),
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
          const SizedBox(width: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 28,
            ), // Ensure text doesn't overflow the 36px box too much
            child: Text(
              event.title,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 6,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w300,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiDayBar(
    Schedule event,
    bool isStart,
    bool isMiddle,
    bool isEnd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 5,
          width: double.infinity,
          margin: EdgeInsets.only(
            left: isStart ? 2.0 : 0.0,
            right: isEnd ? 2.0 : 0.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD8FD),
            borderRadius: BorderRadius.horizontal(
              left: isStart ? const Radius.circular(2.5) : Radius.zero,
              right: isEnd ? const Radius.circular(2.5) : Radius.zero,
            ),
          ),
        ),
        if (isStart)
          Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 1.0),
            child: Text(
              event.title,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 6,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w300,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
      ],
    );
  }
}
