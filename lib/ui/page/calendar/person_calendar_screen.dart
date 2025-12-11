import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../home/home_controller.dart';
import 'person_calendar/person_calendar_controller.dart';
import '../../../../data/model/schedule.dart';

class PersonCalendarScreen extends StatelessWidget {
  final String personId;

  const PersonCalendarScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final controller = Get.put(
      PersonCalendarController(personId: personId),
      tag: personId,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const SizedBox(width: 16),
          Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${controller.focusedDay.value.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF979797),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${controller.focusedDay.value.month}',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Obx(
            () => TableCalendar<Schedule>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              calendarFormat: CalendarFormat.month,
              headerVisible: false,
              selectedDayPredicate: (day) {
                return isSameDay(controller.selectedDay.value, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                controller.onDaySelected(selectedDay, focusedDay);
              },
              onPageChanged: (focusedDay) {
                controller.onPageChanged(focusedDay);
              },
              eventLoader: (day) => controller.getEventsForDay(day),
              daysOfWeekHeight: 30,
              rowHeight: 60,
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) =>
                    DateFormat.E(locale).format(date),
                decoration: const BoxDecoration(color: Colors.white),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Colors.transparent),
                todayDecoration: BoxDecoration(color: Colors.transparent),
                selectedTextStyle: TextStyle(color: Colors.black, fontSize: 14),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final text = DateFormat.E().format(day);
                  Color color = const Color(0xFF4A4A4A);
                  if (day.weekday == DateTime.sunday)
                    color = const Color(0xFFFF0000);
                  if (day.weekday == DateTime.saturday)
                    color = const Color(0xFF0084FF);
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  final events = controller.getEventsForDay(day);
                  final firstEvent = events.isNotEmpty ? events.first : null;

                  Color dayColor = Colors.black;
                  if (day.weekday == DateTime.sunday) {
                    dayColor = const Color(0xFFFF0000);
                  } else if (day.weekday == DateTime.saturday) {
                    dayColor = const Color(0xFF0084FF);
                  }

                  return _buildDayCell(
                    day: day,
                    event: firstEvent,
                    dayTextStyle: TextStyle(
                      color: dayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final events = controller.getEventsForDay(day);
                  final firstEvent = events.isNotEmpty ? events.first : null;
                  return _buildDayCell(
                    day: day,
                    event: firstEvent,
                    dayTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final events = controller.getEventsForDay(day);
                  final firstEvent = events.isNotEmpty ? events.first : null;
                  return _buildDayCell(
                    day: day,
                    event: firstEvent,
                    dayTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  final events = controller.getEventsForDay(day);
                  final firstEvent = events.isNotEmpty ? events.first : null;

                  Color dayColor = Colors.black.withOpacity(0.3);
                  if (day.weekday == DateTime.sunday) {
                    dayColor = const Color(0xFFFF0000).withOpacity(0.3);
                  } else if (day.weekday == DateTime.saturday) {
                    dayColor = const Color(0xFF0084FF).withOpacity(0.3);
                  }

                  return _buildDayCell(
                    day: day,
                    event: firstEvent,
                    dayTextStyle: TextStyle(
                      color: dayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Add Schedule Button
          GestureDetector(
            onTap: () {
              controller.addSchedule();
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
                    child: const Icon(Icons.add, size: 10, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '이 사람과의 일정 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Planned Schedules List (Important ones)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9D9D9D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      // Filter important schedules from all loaded events?
                      // Since events is a Map, we iterate.
                      // Or better, logic in controller. For now, filter here.
                      final allEvents = controller.events.values
                          .expand((element) => element)
                          .toSet()
                          .toList(); // unique
                      // Sort?
                      final importantEvents = allEvents
                          .where((s) => s.isImportant)
                          .toList();

                      if (importantEvents.isEmpty) {
                        return const Text(
                          "중요한 일정이 없습니다.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }

                      return ListView.builder(
                        itemCount: importantEvents.length,
                        itemBuilder: (context, index) {
                          final schedule = importantEvents[index];
                          final dateStr = DateFormat(
                            'yy년 M월 d일',
                            'ko_KR',
                          ).format(schedule.startDateTime);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildScheduleCard(dateStr, schedule.title),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: 1, // Calendar tab
            onTap: (index) {
              // Navigation stub
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
    );
  }

  int getCategoryColor(Schedule event) {
    if (event.groupId != null) {
      final homeController = Get.find<HomeController>();
      final group = homeController.groups.firstWhereOrNull(
        (g) => g.id == event.groupId,
      );
      if (group != null) {
        return group.colorValue;
      }
    }
    return 0xFFD9D9D9; // Default gray
  }

  Widget _buildDayCell({
    required DateTime day,
    required Schedule? event,
    required TextStyle dayTextStyle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${day.day}', style: dayTextStyle),
        const SizedBox(height: 4),
        SizedBox(
          height: 18, // Fixed height for event text area
          child: event == null
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color Tag
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(getCategoryColor(event)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Title
                    Flexible(
                      child: Text(
                        event.title.length > 4
                            ? '${event.title.substring(0, 4)}…'
                            : event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(String line1, String line2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line1,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: Color(0xFF464646),
              height: 1.5,
            ),
          ),
          Text(
            line2,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: Color(0xFF464646),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
