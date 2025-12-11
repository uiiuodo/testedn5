import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'person_calendar_controller.dart';
import '../../../../data/model/schedule.dart';
import '../schedule_edit_screen.dart';
import '../../../widgets/calendar/day_events_sheet.dart';
import '../../../widgets/calendar/planned_task_list.dart';
import '../../home/home_controller.dart';
import '../../../widgets/common/refreshable_layout.dart';

class PersonCalendarScreen extends GetView<PersonCalendarController> {
  const PersonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if using Get.put in parent, or Get.find here.
    // Since we extend GetView, controller is already available.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                      if (controller.isOnTodayMonth)
                                        return const SizedBox.shrink();
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
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
                                                ? Colors.black
                                                : const Color(0xFF979797),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                          Obx(() {
                            // Explicitly depend on reactive variables to trigger rebuilds
                            // ignore: unused_local_variable
                            final _ = controller.events.length;

                            return TableCalendar(
                              firstDay: DateTime(2020, 1, 1),
                              lastDay: DateTime(2030, 12, 31),
                              focusedDay: controller.focusedDay.value,
                              selectedDayPredicate: (day) =>
                                  isSameDay(controller.selectedDay.value, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                controller.selectedDay.value = selectedDay;
                                controller.focusedDay.value = focusedDay;
                                if (controller.sheetController.isAttached) {
                                  controller.sheetController.animateTo(
                                    0.5,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              headerVisible: false,
                              daysOfWeekHeight: 20,
                              rowHeight: 60, // 1) Modified rowHeight
                              calendarFormat: CalendarFormat.month,
                              availableGestures:
                                  AvailableGestures.horizontalSwipe,
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
                              calendarStyle: const CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                selectedTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
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
                                defaultBuilder: (context, day, focusedDay) =>
                                    _buildDayCell(controller, day, false),
                                selectedBuilder: (context, day, focusedDay) =>
                                    _buildDayCell(controller, day, false),
                                todayBuilder: (context, day, focusedDay) =>
                                    _buildDayCell(
                                      controller,
                                      day,
                                      false,
                                      isToday: true,
                                    ),
                                outsideBuilder: (context, day, focusedDay) =>
                                    _buildDayCell(
                                      controller,
                                      day,
                                      false,
                                      isOutside: true,
                                    ),
                                markerBuilder: (context, day, events) =>
                                    const SizedBox.shrink(),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
                          const Divider(thickness: 1, color: Color(0xFFF5F5F5)),

                          const SizedBox(height: 10),
                          const SizedBox(height: 10),
                          // Add Schedule Button
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Get.bottomSheet(
                                  ScheduleEditScreen(
                                    initialDate:
                                        controller.selectedDay.value ??
                                        DateTime.now(),
                                    isPlanned:
                                        false, // Always false for confirmed schedule
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
                          // Planned Tasks List
                          Obx(
                            () => PlannedTaskList(
                              tasks: controller.plannedTasks.toList(),
                              onAdd: controller.addPlannedTask,
                              onUpdate: controller.updatePlannedTask,
                              onDelete: controller.deletePlannedTask,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
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
                      currentIndex: 1,
                      onTap: (index) {
                        if (index == 0) Get.back();
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
            // Day Events Bottom Sheet
            Obx(() {
              final selectedDay = controller.selectedDay.value;
              if (selectedDay == null) return const SizedBox.shrink();

              final homeController = Get.find<HomeController>();

              return DraggableScrollableSheet(
                controller: controller.sheetController,
                initialChildSize: 0.15,
                minChildSize: 0.15,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.15, 0.5, 0.9],
                builder: (context, scrollController) {
                  final dayEvents = controller.getEventsForDay(selectedDay);
                  return DayEventsSheet(
                    controller: controller.sheetController,
                    scrollController: scrollController,
                    selectedDate: selectedDay,
                    events: dayEvents,
                    homeController: homeController,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    PersonCalendarController controller,
    DateTime day,
    bool isSelected, {
    bool isToday = false,
    bool isOutside = false,
  }) {
    final items = controller.getDayItems(day);
    Color dayColor = const Color(0xFF4A4A4A);
    if (day.weekday == DateTime.sunday)
      dayColor = const Color(0xFFFF0000);
    else if (day.weekday == DateTime.saturday)
      dayColor = const Color(0xFF0084FF);
    if (isOutside) dayColor = dayColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFF2F2F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: const Color(0xFF4A4A4A), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 6),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: dayColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Event List
          Container(
            height: 22, // Requested: 22px fixed height
            margin: const EdgeInsets.only(
              bottom: 2,
            ), // Requested: margin bottom <= 2
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ), // Requested: horizontal 4, vertical 0
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Requested: mainAxisSize min
              children: [
                ...items.take(1).map((item) {
                  // take(1) to fit in 22px (font 10 ~ 14px height)
                  return Row(
                    children: [
                      Container(
                        width: 2,
                        height: 10, // Adjust to match font scale
                        color: item.groupColor != null
                            ? Color(item.groupColor!)
                            : const Color(0xFFD9D9D9),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 10, // Requested: fontSize 10
                            color: Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w400,
                            overflow:
                                TextOverflow.ellipsis, // Requested: ellipsis
                            height: 1.0,
                          ),
                          maxLines: 1, // Requested: maxLines 1
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
