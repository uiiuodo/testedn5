import 'package:get/get.dart';
import '../../../data/model/person.dart';
import '../../../data/repository/person_repository.dart';

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
  final PersonRepository _personRepository = PersonRepository();

  final RxList<AppNotification> allNotifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingEvents();
  }

  void fetchUpcomingEvents() {
    final people = _personRepository.getPeople();
    final today = DateTime.now();
    final List<AppNotification> notifications = [];

    for (final person in people) {
      // Check Birthday
      if (person.birthDate != null) {
        final daysUntil = _calculateDaysUntil(today, person.birthDate!);
        if (daysUntil >= 0 && daysUntil <= 30) {
          notifications.add(
            AppNotification(
              id: '${person.id}_birthday',
              title: '${person.name} 생일',
              dDay: daysUntil == 0 ? 'D-day' : 'D-$daysUntil',
              type: NotificationType.anniversary,
            ),
          );
        }
      }

      // Check Anniversaries
      for (final anniversary in person.anniversaries) {
        final daysUntil = _calculateDaysUntil(today, anniversary.date);
        if (daysUntil >= 0 && daysUntil <= 30) {
          notifications.add(
            AppNotification(
              id: '${person.id}_${anniversary.id}',
              title: '${person.name} ${anniversary.title}',
              dDay: daysUntil == 0 ? 'D-day' : 'D-$daysUntil',
              type: NotificationType.anniversary,
            ),
          );
        }
      }
    }

    // Sort by days remaining (D-day first)
    notifications.sort((a, b) {
      final aDays = _parseDDay(a.dDay);
      final bDays = _parseDDay(b.dDay);
      return aDays.compareTo(bDays);
    });

    allNotifications.value = notifications;
  }

  int _calculateDaysUntil(DateTime today, DateTime eventDate) {
    // Get this year's occurrence
    DateTime thisYearEvent = DateTime(
      today.year,
      eventDate.month,
      eventDate.day,
    );

    // If the event has passed this year, check next year
    if (thisYearEvent.isBefore(DateTime(today.year, today.month, today.day))) {
      thisYearEvent = DateTime(today.year + 1, eventDate.month, eventDate.day);
    }

    return thisYearEvent
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  int _parseDDay(String dDay) {
    if (dDay == 'D-day') return 0;
    return int.tryParse(dDay.replaceAll('D-', '')) ?? 999;
  }

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
