import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              final anniversaryList = notifications
                  .where((n) => n.type == NotificationType.anniversary)
                  .toList();
              final careList = notifications
                  .where((n) => n.type == NotificationType.care)
                  .toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                children: [
                  if (anniversaryList.isNotEmpty) ...[
                    _buildSectionHeader('기념일', Icons.calendar_today_outlined),
                    const SizedBox(height: 10),
                    ...anniversaryList.map((n) => _buildNotificationItem(n)),
                    const SizedBox(height: 24),
                  ],
                  if (careList.isNotEmpty) ...[
                    _buildSectionHeader('챙기기', Icons.check_circle_outline),
                    const SizedBox(height: 10),
                    ...careList.map((n) => _buildNotificationItem(n)),
                  ],
                ],
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFA6A6A6)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFA6A6A6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Noto Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 43,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24), // Approx padding to align with design
          SizedBox(
            width: 50, // Fixed width for D-Day to align titles
            child: Text(
              notification.dDay,
              style: const TextStyle(
                color: Color(0xFF595959),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Noto Sans',
              ),
            ),
          ),
          Text(
            notification.title,
            style: const TextStyle(
              color: Color(0xFF595959),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Noto Sans',
            ),
          ),
        ],
      ),
    );
  }
}
