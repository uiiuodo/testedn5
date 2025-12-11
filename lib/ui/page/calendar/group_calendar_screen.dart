import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../home/home_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'group_calendar_controller.dart';
import '../../../../data/model/schedule.dart';
import 'schedule_edit_screen.dart';
import '../../widgets/common/refreshable_layout.dart';
import '../../widgets/common/group_management_bottom_sheet.dart';

class GroupCalendarScreen extends StatefulWidget {
  const GroupCalendarScreen({super.key});

  @override
  State<GroupCalendarScreen> createState() => _GroupCalendarScreenState();
}

class _GroupCalendarScreenState extends State<GroupCalendarScreen> {
  // UI State for Dropdown and BottomSheet
  bool _isDropdownOpen = false;
  bool _isBottomSheetOpen = false;
  final TextEditingController _groupNameController = TextEditingController();
  int _selectedColorValue = 0xFFFFE9E9; // Default color

  final List<int> _groupColors = [
    0xFFFFE9E9,
    0xFFFFECD7,
    0xFFFFF7C7,
    0xFFDFFFC7,
    0xFFD6FAFF,
    0xFFC0DCFF,
    0xFFEED3FF,
    0xFFD9D9D9,
  ];

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(GroupCalendarController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Main Content
            Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Back Button and Right Column (Pen, Year, Month)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Back Button
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () {
                              homeController.changeTab(0);
                            },
                          ),

                          // Right: Pen Icon + Year + Month
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Pen Icon
                              IconButton(
                                icon: Obx(
                                  () => Icon(
                                    controller.isEditMode.value
                                        ? Icons.edit
                                        : Icons.edit_outlined,
                                    color: controller.isEditMode.value
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                onPressed: controller.toggleEditMode,
                              ),
                              const SizedBox(height: 4),

                              // Year (e.g., 2025)
                              Obx(
                                () => Text(
                                  '${controller.focusedDay.value.year}',
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              // Month (e.g., 12)
                              Obx(
                                () => Text(
                                  '${controller.focusedDay.value.month}',
                                  style: AppTextStyles.header1.copyWith(
                                    fontSize: 32,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 2: Filter Buttons (Total / Select)
                      Row(
                        children: [
                          Obx(() {
                            final isAllSelected =
                                controller.selectedGroupId.value == 'all';
                            return _buildFilterButton(
                              text: '전체',
                              isSelected: isAllSelected,
                              onTap: () {
                                controller.selectGroup('all');
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                              },
                            );
                          }),
                          const SizedBox(width: 8),
                          Obx(() {
                            final selectedGroup = homeController.groups
                                .firstWhereOrNull(
                                  (g) =>
                                      g.id == controller.selectedGroupId.value,
                                );
                            final label = selectedGroup?.name ?? '선택';
                            final isSelectActive =
                                controller.selectedGroupId.value != 'all';

                            return _buildFilterButton(
                              text: label,
                              isSelected: isSelectActive || _isDropdownOpen,
                              hasDropdown: true,
                              onTap: () {
                                setState(() {
                                  _isDropdownOpen = !_isDropdownOpen;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 3: Group Legend
                      Obx(() {
                        if (controller.selectedGroupId.value != 'all') {
                          return const SizedBox.shrink();
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: homeController.usedGroups.map((group) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(group.colorValue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      group.name,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshableLayout(
                    onRefresh: () async {
                      await controller.fetchSchedules();
                      await homeController.fetchGroups();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Obx(
                              () => TableCalendar<Schedule>(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: controller.focusedDay.value,
                                calendarFormat: CalendarFormat.month,
                                headerVisible: false,
                                selectedDayPredicate: (day) {
                                  return isSameDay(
                                    controller.selectedDay.value,
                                    day,
                                  );
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  controller.selectedDay.value = selectedDay;
                                  controller.focusedDay.value = focusedDay;
                                },
                                onPageChanged: (focusedDay) {
                                  controller.focusedDay.value = focusedDay;
                                },

                                daysOfWeekHeight: 20,
                                rowHeight: 60,
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                ),
                                calendarStyle: const CalendarStyle(
                                  // Transparent decorations to avoid default circles/squares
                                  selectedDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.rectangle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.rectangle,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  dowBuilder: (context, day) {
                                    final text = DateFormat.E().format(day);
                                    Color color = const Color(0xFF4A4A4A);
                                    if (day.weekday == DateTime.sunday) {
                                      color = const Color(0xFFFF0000);
                                    }
                                    if (day.weekday == DateTime.saturday) {
                                      color = const Color(0xFF0084FF);
                                    }
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
                                    final items = controller.getDayItems(day);
                                    final firstEvent = items.isNotEmpty
                                        ? items.first
                                        : null;

                                    // Determine text style based on day of week
                                    Color dayColor = AppColors.textPrimary;
                                    if (day.weekday == DateTime.sunday) {
                                      dayColor = const Color(0xFFFF0000);
                                    } else if (day.weekday ==
                                        DateTime.saturday) {
                                      dayColor = const Color(0xFF0084FF);
                                    }

                                    return _buildDayCell(
                                      day: day,
                                      event: firstEvent,
                                      dayTextStyle: TextStyle(
                                        color: dayColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                  todayBuilder: (context, day, focusedDay) {
                                    final items = controller.getDayItems(day);
                                    final firstEvent = items.isNotEmpty
                                        ? items.first
                                        : null;
                                    return _buildDayCell(
                                      day: day,
                                      event: firstEvent,
                                      dayTextStyle: const TextStyle(
                                        color: Colors.black, // Today color
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                  selectedBuilder: (context, day, focusedDay) {
                                    final items = controller.getDayItems(day);
                                    final firstEvent = items.isNotEmpty
                                        ? items.first
                                        : null;
                                    return _buildDayCell(
                                      day: day,
                                      event: firstEvent,
                                      dayTextStyle: const TextStyle(
                                        color: Colors.black, // Selected color
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                  outsideBuilder: (context, day, focusedDay) {
                                    final items = controller.getDayItems(day);
                                    final firstEvent = items.isNotEmpty
                                        ? items.first
                                        : null;

                                    // Outside color logic
                                    Color dayColor = AppColors.textPrimary;
                                    if (day.weekday == DateTime.sunday) {
                                      dayColor = const Color(0xFFFF0000);
                                    } else if (day.weekday ==
                                        DateTime.saturday) {
                                      dayColor = const Color(0xFF0084FF);
                                    }
                                    dayColor = dayColor.withOpacity(0.3);

                                    return _buildDayCell(
                                      day: day,
                                      event: firstEvent,
                                      dayTextStyle: TextStyle(
                                        color: dayColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                  markerBuilder: (context, day, events) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Add Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GestureDetector(
                              onTap: () async {
                                // Add group schedule - Always create new
                                final result = await Get.bottomSheet(
                                  ScheduleEditScreen(
                                    initialDate:
                                        controller.selectedDay.value ??
                                        DateTime.now(),
                                    isPlanned: true,
                                    // No personId for group schedule
                                    personId: null,
                                  ),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                                if (result != null && result is Schedule) {
                                  controller.addSchedule(result);
                                } else {
                                  controller.fetchSchedules();
                                }
                              },
                              child: Container(
                                width: double.infinity,
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
                                    Text(
                                      '일정 추가하기',
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Planned Schedules List
                          Padding(
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
                                Obx(
                                  () => Column(
                                    children: controller
                                        .filteredPlannedSchedules
                                        .map(
                                          (schedule) => _buildScheduleCard(
                                            controller,
                                            schedule,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Dropdown Overlay
            if (_isDropdownOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDropdownOpen = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Positioned(
                          left:
                              24 +
                              50 +
                              8, // Approx position: Padding + Total Btn + Gap
                          top: 10 + 24 + 20 + 26 + 5, // Approx top offset
                          child: Container(
                            width: 135,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFBFB),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...homeController.groups.map(
                                    (group) => InkWell(
                                      onTap: () {
                                        controller.selectGroup(group.id);
                                        setState(() {
                                          _isDropdownOpen = false;
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 26,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          group.name,
                                          style: AppTextStyles.body1.copyWith(
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFECECEC),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isDropdownOpen = false;
                                        _isBottomSheetOpen = true;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 26,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        '그룹 추가하기',
                                        style: AppTextStyles.body1.copyWith(
                                          fontWeight: FontWeight.w300,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isDropdownOpen = false;
                                      });
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => Obx(
                                          () => GroupManagementBottomSheet(
                                            groups: homeController.groups
                                                .toList(),
                                            onRename: (id, newName) {
                                              homeController.updateGroup(
                                                id,
                                                newName,
                                              );
                                            },
                                            onDelete: (id) {
                                              homeController.deleteGroup(id);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 26,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        '그룹 편집하기',
                                        style: AppTextStyles.body1.copyWith(
                                          fontWeight: FontWeight.w300,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Bottom Sheet Dim Background
            if (_isBottomSheetOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBottomSheetOpen = false;
                    });
                  },
                  child: Container(color: Colors.black.withOpacity(0.43)),
                ),
              ),

            // 4. Bottom Sheet
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _isBottomSheetOpen ? 0 : -341,
              height: 341,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 51,
                  vertical: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '그룹 추가하기',
                      style: AppTextStyles.header2.copyWith(
                        fontWeight: FontWeight.w300,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Group Name Input
                    Container(
                      height: 31,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.5),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _groupNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: '그룹 이름 입력하기',
                          hintStyle: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w300,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Selection
                    Row(
                      children: [
                        Text(
                          '컬러',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 12),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: _groupColors.map((colorValue) {
                        final isSelected = _selectedColorValue == colorValue;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColorValue = colorValue;
                            });
                          },
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 1)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_groupNameController.text.isNotEmpty) {
                            controller.addGroup(
                              _groupNameController.text,
                              _selectedColorValue,
                            );
                            _groupNameController.clear();
                            setState(() {
                              _isBottomSheetOpen = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF414141),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.5),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '등록하기',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasDropdown = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B3B3B) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF4C4C4C), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                color: isSelected ? Colors.white : const Color(0xFF565656),
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF565656),
              ),
            ],
          ],
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

  Widget _buildScheduleCard(
    GroupCalendarController controller,
    Schedule schedule,
  ) {
    // Split title by newline to get line1 and line2 if possible
    final lines = schedule.title.split('\n');
    final line1 = lines.isNotEmpty ? lines[0] : schedule.title;
    final line2 = lines.length > 1 ? lines[1] : '';

    return GestureDetector(
      onTap: () async {
        // If in edit mode, tap could also trigger edit, but user said:
        // "If currently tap does nothing, keep it that way."
        // "In Edit Mode, show controls."
        // So we only add controls in Edit Mode.
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
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
                  if (line2.isNotEmpty)
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
            ),
            // Edit/Delete Controls
            if (controller.isEditMode.value)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Edit
                      final result = await Get.bottomSheet(
                        ScheduleEditScreen(
                          schedule: schedule,
                          isPlanned: true,
                          personId: null,
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                      if (result != null && result is Schedule) {
                        controller.updateSchedule(result);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF9D9D9D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Delete
                      Get.dialog(
                        AlertDialog(
                          title: const Text('일정 삭제'),
                          content: const Text('이 일정을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.deletePlannedSchedule(schedule.id);
                                Get.back();
                              },
                              child: const Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.delete,
                        size: 16,
                        color: Color(0xFF9D9D9D),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
