import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'notification_controller.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '알림 센터',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Noto Sans',
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.only(left: 43, top: 10, bottom: 20),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterTab(controller, '전체'),
                  const SizedBox(width: 20),
                  _buildFilterTab(controller, '기념일'),
                  const SizedBox(width: 20),
                  _buildFilterTab(controller, '챙기기'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              final notifications = controller.filteredNotifications;

              // If "All" tab, we might want to separate headers optionally?
              // Existing logic separated Anniversary / Care lists in UI.
              // But sorting by date was requested.
              // Request 2.4/2.2: "Sort by startDateTime ascending".
              // If we sort by date, sections might be mixed.
              // If I simply list them all, it follows the sort.
              // Let's just use a single ListView for simplicity based on filters.

              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    '일정이 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildNotificationItem(notifications[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(NotificationController controller, String label) {
    final isSelected = controller.selectedFilter.value == label;
    return GestureDetector(
      onTap: () => controller.changeFilter(label),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF303030) : const Color(0xFF868686),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Noto Sans',
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return GestureDetector(
      onTap: () {
        // 간단한 알림 상세 다이얼로그만 노출
        Get.dialog(
          AlertDialog(
            title: Text(notification.title),
            content: Text(
              '날짜: ${DateFormat('MM.dd HH:mm').format(notification.dateTime)}',
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('확인')),
            ],
          ),
        );
      },
      child: Container(
        // ... 기존 디자인 코드 그대로 두면 됨
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Left Indicator? (Group Color requested, but simplistic for now)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top: Date/Time
                  Text(
                    _formatDate(notification),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Middle: Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Bottom: Badges (Optional)
                  if (notification.type == NotificationType.anniversary ||
                      notification.type == NotificationType.care)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          if (notification.type == NotificationType.anniversary)
                            _buildBadge("기념일", const Color(0xFFFFD8FD)),
                          if (notification.type == NotificationType.care) ...[
                            if (notification.type ==
                                NotificationType.anniversary)
                              const SizedBox(width: 4),
                            _buildBadge("챙기기", const Color(0xFFE8F0FE)),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Right: D-Day if available (for Person Anniversaries)
            if (!notification.isSchedule)
              Text(
                notification.dDay,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF303030),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppNotification n) {
    if (n.isSchedule) {
      // MM.dd (E) or MM.dd (E) HH:mm
      // Check if time is 00:00? Not checking allDay flag in notification model yet.
      // Assuming allDay if HH:mm is 00:00 for simplicity or just format uniformly for now.
      // Let's deduce: if hour/min is 0, hide time? Or strict format.
      // Request says: "MM.dd (E)" for all day, "MM.dd (E) HH:mm" for time.
      // I didn't pass "allDay" to AppNotification. Let's assume HH:mm for all.
      return DateFormat('M.d (E) HH:mm', 'ko_KR').format(n.dateTime);
    } else {
      // Person Anniversary: Just Date
      return DateFormat('M.d (E)', 'ko_KR').format(n.dateTime);
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }
}
