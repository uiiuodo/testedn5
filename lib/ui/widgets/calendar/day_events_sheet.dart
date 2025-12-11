import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/schedule.dart';
import '../../page/home/home_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DayEventsSheet extends StatelessWidget {
  final ScrollController scrollController;
  final DateTime selectedDate;
  final List<Schedule> events;
  final HomeController homeController;
  final Function(Schedule) onTapSchedule;
  final Function(String) onDeleteSchedule;

  const DayEventsSheet({
    super.key,
    required this.scrollController,
    required this.selectedDate,
    required this.events,
    required this.homeController,
    required this.onTapSchedule,
    required this.onDeleteSchedule,
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
                  const Text(
                    '챙기기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9D9D9D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...careEvents
                      .map(
                        (e) => _EventItem(
                          schedule: e,
                          homeController: homeController,
                          onTap: () => onTapSchedule(e),
                          onDelete: () => onDeleteSchedule(e.id),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 20),
                ] else if (anniversaryEvents.isEmpty) ...[
                  // Handled by the empty check below
                ],
                if (anniversaryEvents.isNotEmpty) ...[
                  const Text(
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
                        (e) => _EventItem(
                          schedule: e,
                          homeController: homeController,
                          isAnniversarySection: true,
                          onTap: () => onTapSchedule(e),
                          onDelete: () => onDeleteSchedule(e.id),
                        ),
                      )
                      .toList(),
                ],
                if (careEvents.isEmpty && anniversaryEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
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
}

class _EventItem extends StatefulWidget {
  final Schedule schedule;
  final HomeController homeController;
  final bool isAnniversarySection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventItem({
    required this.schedule,
    required this.homeController,
    this.isAnniversarySection = false,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_EventItem> createState() => _EventItemState();
}

class _EventItemState extends State<_EventItem> {
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    // Find Group Color
    int colorValue = 0xFFD9D9D9; // Default gray
    if (widget.schedule.groupId != null) {
      final group = widget.homeController.groups.firstWhereOrNull(
        (g) => g.id == widget.schedule.groupId,
      );
      if (group != null) {
        colorValue = group.colorValue;
      }
    }

    return GestureDetector(
      onTap: () {
        if (_isDeleteMode) {
          setState(() {
            _isDeleteMode = false;
          });
        } else {
          widget.onTap();
        }
      },
      onLongPress: () {
        if (!_isDeleteMode) {
          setState(() {
            _isDeleteMode = true;
          });
        }
      },
      child: Container(
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
                    widget.schedule.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!widget.isAnniversarySection &&
                      !widget.schedule.allDay) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.schedule.startDateTime.hour > 12 ? '오후 ${widget.schedule.startDateTime.hour - 12}' : '오전 ${widget.schedule.startDateTime.hour}'}:${widget.schedule.startDateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9D9D9D),
                      ),
                    ),
                  ] else if (widget.isAnniversarySection) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '매년 반복',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9D9D9D)),
                    ),
                  ],
                ],
              ),
            ),
            if (_isDeleteMode)
              GestureDetector(
                onTap: _showDeleteDialog,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onDelete(); // Perform delete
              setState(() {
                _isDeleteMode = false;
              });
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
