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
import '../../widgets/common/group_add_bottom_sheet.dart';
import '../../widgets/common/group_dropdown_menu.dart';
import '../../widgets/common/group_management_bottom_sheet.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  // State variables for UI flow
  bool _isDropdownOpen =
      false; // Kept for button state visual if needed, though dropdown is modal now
  final GlobalKey _groupButtonKey = GlobalKey();

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

                        return GestureDetector(
                          key: _groupButtonKey,
                          onTap: () {
                            final RenderBox renderBox =
                                _groupButtonKey.currentContext!
                                        .findRenderObject()
                                    as RenderBox;
                            final offset = renderBox.localToGlobal(Offset.zero);
                            final position = RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + renderBox.size.height,
                              offset.dx + renderBox.size.width,
                              offset.dy + renderBox.size.height + 200,
                            );

                            setState(() {
                              _isDropdownOpen = true;
                            });

                            showGroupDropdown(
                              context,
                              position: position,
                              groups: controller.groups,
                              onGroupSelected: (group) {
                                controller.selectGroup(group.id);
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                              },
                              onAddGroup: () {
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => GroupAddBottomSheet(
                                    onAdd: (name, colorValue) {
                                      controller.addGroup(name, colorValue);
                                      Get.back();
                                    },
                                  ),
                                );
                              },
                              onEditGroups: () {
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      GroupManagementBottomSheet(
                                        groups: controller.groups,
                                        onRename: (id, newName) {
                                          controller.updateGroup(id, newName);
                                        },
                                        onDelete: (id) {
                                          controller.deleteGroup(id);
                                        },
                                      ),
                                );
                              },
                            ).then((_) {
                              if (mounted) {
                                setState(() {
                                  _isDropdownOpen = false;
                                });
                              }
                            });
                          },
                          child: _buildPillButton(
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
                            onTap: null, // Handled by GestureDetector
                          ),
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
                          controller.isReorderMode.value = false;
                        },
                        itemBuilder: (context, index) {
                          final person = people[index];
                          final group = controller.groups.firstWhereOrNull(
                            (g) => g.id == person.groupId,
                          );
                          final color = group != null
                              ? Color(group.colorValue)
                              : Colors.grey;

                          return Dismissible(
                            key: ValueKey(person.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    '삭제',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('삭제 확인'),
                                    content: Text('${person.name}님을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              controller.deletePerson(person.id);
                            },
                            child: Container(
                              color: Colors.white, // Background for drag proxy
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      controller.isReorderMode.value = true;
                                    },
                                    child: InkWell(
                                      onTap: () {
                                        // If in reorder mode, maybe just exit mode?
                                        // Or navigate? User said "existing behavior intact".
                                        // Let's navigate and also turn off mode.
                                        controller.isReorderMode.value = false;
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ),
                                            // Drag Handle
                                            Obx(() {
                                              return Visibility(
                                                visible: controller
                                                    .isReorderMode
                                                    .value,
                                                child: ReorderableDragStartListener(
                                                  index: index,
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .menu, // Hamburger icon
                                                      color: AppColors
                                                          .textTertiary,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String text,
    required bool isSelected,
    VoidCallback? onTap,
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
