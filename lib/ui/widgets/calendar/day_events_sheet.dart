import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/schedule.dart';
import '../../page/home/home_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DayEventsSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final ScrollController scrollController;
  final DateTime selectedDate;
  final List<Schedule> events;
  final HomeController homeController;

  const DayEventsSheet({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.selectedDate,
    required this.events,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    // Filter events
    final careEvents = events
        .where((s) => !s.isAnniversary || s.id.startsWith('birthday_'))
        .toList();
    final anniversaryEvents = events
        .where((s) => s.isAnniversary && !s.id.startsWith('birthday_'))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('yyyy.MM.dd').format(selectedDate),
                        style: AppTextStyles.header2.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '챙기기 ${careEvents.length} · 기념일 ${anniversaryEvents.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (careEvents.isNotEmpty) ...[
                  Text(
                    '챙기기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9D9D9D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...careEvents
                      .map((e) => _buildEventItem(e, homeController))
                      .toList(),
                  const SizedBox(height: 20),
                ] else if (anniversaryEvents.isEmpty) ...[
                  // Both empty?
                  // Logic handled below, but if only care is empty we just don't show it?
                  // User said "If empty... show one line 'No events'".
                  // But wait, if both empty, maybe show "No events for this day".
                ],
                if (anniversaryEvents.isNotEmpty) ...[
                  Text(
                    '기념일',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9D9D9D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...anniversaryEvents
                      .map(
                        (e) => _buildEventItem(
                          e,
                          homeController,
                          isAnniversarySection: true,
                        ),
                      )
                      .toList(),
                ],
                if (careEvents.isEmpty && anniversaryEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        '챙길 일정이 없습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9D9D9D),
                          fontFamily: 'Noto Sans',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(
    Schedule schedule,
    HomeController homeController, {
    bool isAnniversarySection = false,
  }) {
    // Find Group Color
    int colorValue = 0xFFD9D9D9; // Default gray
    if (schedule.groupId != null) {
      final group = homeController.groups.firstWhereOrNull(
        (g) => g.id == schedule.groupId,
      );
      if (group != null) {
        colorValue = group.colorValue;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5F5F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: Color(colorValue),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isAnniversarySection && !schedule.allDay) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${schedule.startDateTime.hour > 12 ? '오후 ${schedule.startDateTime.hour - 12}' : '오전 ${schedule.startDateTime.hour}'}:${schedule.startDateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ] else if (isAnniversarySection) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '매년 반복',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9D9D9D)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
