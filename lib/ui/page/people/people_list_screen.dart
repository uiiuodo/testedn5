import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../home/home_controller.dart';
import 'person_edit_screen.dart';
import 'person_detail_screen.dart';
import 'dart:ui';
import '../notification/notification_center_screen.dart';
import '../../widgets/common/refreshable_layout.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  // State variables for UI flow
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
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Main Content Layer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Top spacing
                // Top Buttons (Total / Select)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Obx(() {
                        final isAllSelected =
                            controller.selectedGroupId.value == 'all';
                        return _buildPillButton(
                          text: '전체',
                          isSelected: isAllSelected,
                          backgroundColor: isAllSelected
                              ? AppColors.textSecondary
                              : Colors.transparent,
                          textColor: isAllSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          borderColor: isAllSelected
                              ? null
                              : AppColors.textSecondary,
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
                        final selectedGroup = controller.groups
                            .firstWhereOrNull(
                              (g) => g.id == controller.selectedGroupId.value,
                            );
                        final label = selectedGroup?.name ?? '선택';
                        final isSelectActive =
                            controller.selectedGroupId.value != 'all';

                        return _buildPillButton(
                          text: label,
                          isSelected: isSelectActive || _isDropdownOpen,
                          backgroundColor: (isSelectActive || _isDropdownOpen)
                              ? AppColors.textSecondary
                              : AppColors.white,
                          textColor: (isSelectActive || _isDropdownOpen)
                              ? AppColors.white
                              : AppColors.textSecondary,
                          borderColor: (isSelectActive || _isDropdownOpen)
                              ? null
                              : AppColors.textSecondary,
                          hasDropdown: true,
                          onTap: () {
                            setState(() {
                              _isDropdownOpen = !_isDropdownOpen;
                            });
                          },
                        );
                      }),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Get.to(() => const NotificationCenterScreen());
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Group Legend
                Obx(() {
                  if (controller.selectedGroupId.value != 'all') {
                    return const SizedBox.shrink();
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: controller.groups.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
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
                              const SizedBox(width: 6),
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
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      onChanged: controller.search,
                      style: AppTextStyles.body2,
                      decoration: InputDecoration(
                        hintText: '검색',
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.inputHint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.inputHint,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Person List
                Expanded(
                  child: Obx(() {
                    final people = controller.filteredPeople;
                    // Note: Sorting is now handled by the controller's order

                    if (people.isEmpty) {
                      return const Center(
                        child: Text(
                          '등록된 사람이 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      );
                    }

                    return RefreshableLayout(
                      onRefresh: () async {
                        await controller.fetchPeople();
                        await controller.fetchGroups();
                      },
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: people.length,
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              final double animValue = Curves.easeInOut
                                  .transform(animation.value);
                              final double elevation = lerpDouble(
                                0,
                                6,
                                animValue,
                              )!;
                              return Material(
                                elevation: elevation,
                                color: Colors.white,
                                shadowColor: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          controller.reorderPeople(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final person = people[index];
                          final group = controller.groups.firstWhereOrNull(
                            (g) => g.id == person.groupId,
                          );
                          final color = group != null
                              ? Color(group.colorValue)
                              : Colors.grey;

                          return Container(
                            key: ValueKey(person.id),
                            color: Colors.white, // Background for drag proxy
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ReorderableDelayedDragStartListener(
                                  index: index,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => PersonDetailScreen(
                                          personId: person.id,
                                        ),
                                      )?.then((_) {
                                        controller.fetchPeople();
                                        controller.fetchGroups();
                                      });
                                    },
                                    child: Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 11,
                                            height: 11,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  offset: const Offset(1, 1),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 28),
                                          Expanded(
                                            child: Text(
                                              person.name,
                                              style: AppTextStyles.header2
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.primary,
                                                  ),
                                            ),
                                          ),
                                          // Drag Handle
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.menu, // Hamburger icon
                                                color: AppColors.textTertiary,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Divider (Custom implementation since ReorderableListView has no separator)
                                if (index < people.length - 1)
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFEBEBEB),
                                    thickness: 1,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),

            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  onPressed: () {
                    Get.to(() => const PersonEditScreen())?.then((_) {
                      controller.fetchPeople();
                      controller.fetchGroups();
                    });
                  },
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
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
                          left: 87, // Aligned with "Select" button approx
                          top: 60, // Below the button
                          child: Container(
                            width: 135,
                            // height: 102, // Dynamic height
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...controller.groups.map(
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
                                        horizontal: 26, // Indent as per HTML1
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
                              ],
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
              bottom: _isBottomSheetOpen ? 0 : -341, // Hide below screen
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '등록하기',
                          style: TextStyle(
                            fontSize: 14,
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

  Widget _buildPillButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    bool hasDropdown = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color(0xFF565656),
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
                color: textColor ?? const Color(0xFF565656),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
