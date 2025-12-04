import 'package:get/get.dart';

enum NotificationType { anniversary, care }

class AppNotification {
  final String id;
  final String title;
  final String dDay;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.dDay,
    required this.type,
  });
}

class NotificationController extends GetxController {
  final RxString selectedFilter = '전체'.obs; // 전체, 기념일, 챙기기

  final List<AppNotification> allNotifications = [
    AppNotification(
      id: '1',
      title: '안은영 생일',
      dDay: 'D-5',
      type: NotificationType.anniversary,
    ),
    AppNotification(
      id: '2',
      title: '김시선 생일',
      dDay: 'D-21',
      type: NotificationType.anniversary,
    ),
    AppNotification(
      id: '3',
      title: '인선 딸 지영 백일',
      dDay: 'D-74',
      type: NotificationType.anniversary,
    ),
    AppNotification(
      id: '4',
      title: '팀 막내 입사 1주년 축하',
      dDay: 'D-day',
      type: NotificationType.care,
    ),
    AppNotification(
      id: '5',
      title: '할머니께 안부 전화드리기',
      dDay: 'D-2',
      type: NotificationType.care,
    ),
  ];

  List<AppNotification> get filteredNotifications {
    if (selectedFilter.value == '전체') {
      return allNotifications;
    } else if (selectedFilter.value == '기념일') {
      return allNotifications
          .where((n) => n.type == NotificationType.anniversary)
          .toList();
    } else {
      return allNotifications
          .where((n) => n.type == NotificationType.care)
          .toList();
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
