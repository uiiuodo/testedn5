import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../people/people_list_screen.dart';
import '../calendar/group_calendar_screen.dart';
import '../mypage/mypage_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: Obx(() {
        switch (controller.tabIndex.value) {
          case 0:
            return const PeopleListScreen();
          case 1:
            return const GroupCalendarScreen();
          case 2:
            return const MyPageScreen();
          default:
            return const PeopleListScreen();
        }
      }),
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
          child: Obx(
            () => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTab,
              selectedItemColor: const Color(0xFF404040), // Darker than A0A0A0
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
      ),
    );
  }
}
