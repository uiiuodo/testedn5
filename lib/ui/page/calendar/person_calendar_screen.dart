import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'schedule_edit_screen.dart';
import '../home/home_page.dart'; // For bottom nav style reuse if needed, but we use Scaffold's bottomNav here

class PersonCalendarScreen extends StatefulWidget {
  final String personId;

  const PersonCalendarScreen({super.key, required this.personId});

  @override
  State<PersonCalendarScreen> createState() => _PersonCalendarScreenState();
}

class _PersonCalendarScreenState extends State<PersonCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dummy events
  final Map<DateTime, List<String>> _events = {
    DateTime.now().add(const Duration(days: 2)): ['데이트'],
    DateTime.now().add(const Duration(days: 5)): ['저녁식사'],
    DateTime.now().add(const Duration(days: 10)): ['전시회'],
  };

  List<String> _getEventsForDay(DateTime day) {
    // Normalize date to remove time

    // Check if any key matches
    for (var key in _events.keys) {
      if (key.year == day.year &&
          key.month == day.month &&
          key.day == day.day) {
        return _events[key] ?? [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_focusedDay.year}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF979797),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_focusedDay.month}',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerVisible: false,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            daysOfWeekHeight: 30,
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) =>
                  DateFormat.E(locale).format(date),
              decoration: const BoxDecoration(color: Colors.white),
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
                return _buildDayCell(day, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, isToday: true);
              },
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                final eventName = events.first as String;
                return Positioned(
                  bottom: 4,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD8FD),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Text(
                        eventName,
                        style: const TextStyle(
                          fontSize: 6,
                          color: Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Add Schedule Button
          GestureDetector(
            onTap: () {
              // Get.toNamed('/calendar/schedule/edit');
              Get.to(() => const ScheduleEditScreen());
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

          // Planned Schedules List
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
                    child: ListView(
                      children: [
                        _buildScheduleCard(
                          '26년 1월 신년맞이 등산계획 (미정)',
                          '> 이도, 인선, 경하',
                        ),
                        const SizedBox(height: 8),
                        _buildScheduleCard('26년 3월 27~29일', '상하이 여행 예정'),
                        const SizedBox(height: 8),
                        _buildScheduleCard(
                          '26년 5월 10일 오후 8시',
                          '이도가 좋아하는 이치코 아오바 내한 공연 예매',
                        ),
                      ],
                    ),
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
              // Handle navigation if needed, or just pop back to home with index
              if (index == 0) {
                Get.offAll(() => const HomePage()); // Go to Home
              } else if (index == 2) {
                // Go to MyPage
              }
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

  Widget _buildDayCell(DateTime day, bool isSelected, {bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFFF5F5F5), // Pastel background
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: isToday ? Colors.blue : Colors.black,
          ),
        ),
      ),
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
