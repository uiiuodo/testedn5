import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/model/preference_category.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_input_field.dart';
import 'preference_add_bottom_sheet.dart';
import '../../widgets/common/group_add_bottom_sheet.dart';
import '../../widgets/common/group_dropdown_menu.dart';
import '../../widgets/common/group_management_bottom_sheet.dart';
import 'person_edit_controller.dart';
import '../home/home_controller.dart';

class PersonEditScreen extends StatelessWidget {
  final String? personId;

  const PersonEditScreen({super.key, this.personId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PersonEditController(personId: personId));
    final FocusNode nameFocusNode = FocusNode();
    final GlobalKey groupButtonKey = GlobalKey();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '', // Empty title
        actions: [
          TextButton(
            onPressed: controller.savePerson,
            child: Text(
              '등록하기',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Name / Nickname & Group Selection
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Inline Input with Hint
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(nameFocusNode);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: TextField(
                        controller: controller.nameController,
                        focusNode: nameFocusNode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A2A2A),
                        ),
                        decoration: InputDecoration(
                          hintText: '이름 / 애칭 (필수)',
                          hintStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF999999),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Group Selection
                  GestureDetector(
                    key: groupButtonKey,
                    onTap: () {
                      final RenderBox renderBox =
                          groupButtonKey.currentContext!.findRenderObject()
                              as RenderBox;
                      final offset = renderBox.localToGlobal(Offset.zero);
                      final position = RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + renderBox.size.height,
                        offset.dx + renderBox.size.width,
                        offset.dy + renderBox.size.height + 200,
                      );

                      // Use all groups from HomeController
                      final homeController = Get.find<HomeController>();

                      showGroupDropdown(
                        context,
                        position: position,
                        groups: homeController.groups,
                        onGroupSelected: (group) {
                          controller.selectedGroupId.value = group.id;
                        },
                        onAddGroup: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => GroupAddBottomSheet(
                              onAdd: (name, colorValue) {
                                controller.addNewGroup(name, colorValue);
                                Get.back(); // Close bottom sheet
                              },
                            ),
                          );
                        },
                        onEditGroups: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Obx(
                              () => GroupManagementBottomSheet(
                                groups: homeController.groups.toList(),
                                onRename: (id, newName) {
                                  controller.updateGroup(id, newName);
                                },
                                onDelete: (id) {
                                  controller.deleteGroup(id);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Obx(() {
                            final groupId = controller.selectedGroupId.value;
                            final group = controller.groups.firstWhereOrNull(
                              (g) => g.id == groupId,
                            );

                            final isPlaceholder = group == null;

                            return Text(
                              group?.name ?? '그룹 설정',
                              style: TextStyle(
                                fontSize: 13,
                                color: isPlaceholder
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFF2A2A2A),
                              ),
                            );
                          }),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Info Fields (Fixed List)
              // Birthday
              Obx(
                () => controller.showBirthDate.value
                    ? _buildInfoRow(
                        label: '생년월일 (선택)',
                        icon: Icons.calendar_today,
                        onIconTap: () {
                          _showBirthDatePicker(context, controller);
                        },
                        onDelete: () {
                          controller.birthDate.value = null;
                          controller.showBirthDate.value = false;
                        },
                        child: GestureDetector(
                          onTap: () {
                            _showBirthDatePicker(context, controller);
                          },
                          child: Obx(() {
                            final date = controller.birthDate.value;
                            final isLunar = controller.isLunarBirth.value;
                            final lunarDate = controller.lunarBirthDate.value;

                            if (date == null) {
                              return const Text(
                                '선택해주세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFCCCCCC),
                                ),
                              );
                            }

                            String text;
                            if (isLunar && lunarDate != null) {
                              text =
                                  '음력 ${DateFormat('yyyy-MM-dd').format(lunarDate)}';
                            } else {
                              text = DateFormat('yyyy-MM-dd').format(date);
                            }

                            return Text(
                              text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2A2A2A),
                              ),
                            );
                          }),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Phone
              Obx(
                () => controller.showPhone.value
                    ? _buildInfoRow(
                        label: '전화번호 (선택)',
                        onDelete: () {
                          controller.phoneController.clear();
                          controller.showPhone.value = false;
                        },
                        child: CustomInputField(
                          controller: controller.phoneController,
                          hint: '입력해주세요',
                          keyboardType: TextInputType.phone,
                          onChanged: (val) {
                            if (val.isNotEmpty)
                              controller.showPhone.value = true;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Address
              Obx(
                () => controller.showAddress.value
                    ? _buildInfoRow(
                        label: '주소 (선택)',
                        onDelete: () {
                          controller.addressController.clear();
                          controller.showAddress.value = false;
                        },
                        child: CustomInputField(
                          controller: controller.addressController,
                          hint: '입력해주세요',
                          onChanged: (val) {
                            if (val.isNotEmpty)
                              controller.showAddress.value = true;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Email
              Obx(
                () => controller.showEmail.value
                    ? _buildInfoRow(
                        label: 'e-mail (선택)',
                        onDelete: () {
                          controller.emailController.clear();
                          controller.showEmail.value = false;
                        },
                        child: CustomInputField(
                          controller: controller.emailController,
                          hint: '입력해주세요',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) {
                            if (val.isNotEmpty)
                              controller.showEmail.value = true;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // MBTI
              Obx(
                () => controller.showMbti.value
                    ? _buildInfoRow(
                        label: 'MBTI (선택)',
                        onDelete: () {
                          controller.mbtiController.clear();
                          controller.showMbti.value = false;
                        },
                        child: CustomInputField(
                          controller: controller.mbtiController,
                          hint: '입력해주세요',
                          onChanged: (val) {
                            if (val.isNotEmpty)
                              controller.showMbti.value = true;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Custom Fields
              Obx(
                () => Column(
                  children: controller.customFields.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final field = entry.value;
                    return Column(
                      children: [
                        _buildInfoRow(
                          label: '${field.key} (선택)',
                          onDelete: () {
                            controller.removeCustomField(index);
                          },
                          child: CustomInputField(
                            controller: field.value,
                            hint: '입력해주세요',
                            onChanged: (val) {},
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Add Custom Field Button
              _buildAddButton(
                label: '기본 정보 추가',
                onTap: () {
                  _showAddCustomFieldDialog(context, controller);
                },
              ),
              const SizedBox(height: 40),

              // 3. Anniversary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF9D9D9D),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '기념일',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9D9D9D),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.addEmptyAnniversary();
                    },
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Obx(
                () => Column(
                  children: List.generate(controller.anniversaries.length, (
                    index,
                  ) {
                    final anniv = controller.anniversaries[index];
                    return Container(
                      key: Key(anniv.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          // Year Toggle
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.updateAnniversary(
                                  index,
                                  anniv.title,
                                  anniv.date,
                                  true,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: anniv.hasYear
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: anniv.hasYear
                                          ? AppColors.primary
                                          : const Color(0xFFDEDEDE),
                                    ),
                                  ),
                                  child: Text(
                                    '연도 포함',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: anniv.hasYear
                                          ? Colors.white
                                          : const Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => controller.updateAnniversary(
                                  index,
                                  anniv.title,
                                  anniv.date,
                                  false,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !anniv.hasYear
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: !anniv.hasYear
                                          ? AppColors.primary
                                          : const Color(0xFFDEDEDE),
                                    ),
                                  ),
                                  child: Text(
                                    '연도 없음',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: !anniv.hasYear
                                          ? Colors.white
                                          : const Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  controller.removeAnniversaryAt(index);
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF9D9D9D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: anniv.title,
                                  onChanged: (val) {
                                    controller.updateAnniversary(
                                      index,
                                      val,
                                      anniv.date,
                                      anniv.hasYear,
                                    );
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '기념일 이름',
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: anniv.date,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    controller.updateAnniversary(
                                      index,
                                      anniv.title,
                                      date,
                                      anniv.hasYear,
                                    );
                                  }
                                },
                                child: Text(
                                  anniv.hasYear
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(anniv.date)
                                      : DateFormat('MM-dd').format(anniv.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Memo Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.edit_note, size: 16, color: Color(0xFF9D9D9D)),
                      SizedBox(width: 6),
                      Text(
                        '메모',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9D9D9D),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.addEmptyMemo();
                    },
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Existing Memos
              Obx(
                () => Column(
                  children: List.generate(controller.memos.length, (index) {
                    final memo = controller.memos[index];
                    return Container(
                      key: Key(memo.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: memo.content,
                              onChanged: (value) {
                                controller.updateMemo(index, value);
                              },
                              maxLines: null,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2A2A2A),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '내용 입력하기',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.removeMemoAt(index);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Preference Section
              Row(
                children: const [
                  Icon(Icons.search, size: 14, color: Color(0xFF9D9D9D)),
                  SizedBox(width: 6),
                  Text(
                    '취향 기록',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Existing Preferences
              Obx(() {
                // Group preferences by category
                final grouped = <String, List<PreferenceCategory>>{};
                for (var p in controller.preferences) {
                  if (!grouped.containsKey(p.title)) grouped[p.title] = [];
                  grouped[p.title]!.add(p);
                }

                return Column(
                  children: grouped.entries.map((entry) {
                    final category = entry.key;
                    final prefs = entry.value;
                    final likesList = prefs
                        .where((p) => p.like != null)
                        .map((p) => p.like!)
                        .toList();
                    final dislikesList = prefs
                        .where((p) => p.dislike != null)
                        .map((p) => p.dislike!)
                        .toList();

                    String formatList(List<String> items) {
                      if (items.isEmpty) return '';
                      final flattened = <String>[];
                      for (var item in items) {
                        // Split by newline and comma to handle legacy data
                        var parts = item.split(RegExp(r'[\n,]'));
                        for (var part in parts) {
                          var clean = part.trim();
                          if (clean.startsWith('•'))
                            clean = clean.substring(1).trim();
                          if (clean.startsWith('·'))
                            clean = clean.substring(1).trim();
                          if (clean.isNotEmpty) flattened.add(clean);
                        }
                      }
                      return flattened.map((e) => '• $e').join('\n');
                    }

                    final likes = formatList(likesList);
                    final dislikes = formatList(dislikesList);

                    final isExpanded = controller.expandedCategories.contains(
                      category,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Header
                          GestureDetector(
                            onTap: () =>
                                controller.toggleCategoryExpansion(category),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Accordion Arrow
                                  AnimatedRotation(
                                    turns: isExpanded
                                        ? 0.0
                                        : -0.25, // Open (Down) = 0.0, Closed (Right) = -0.25
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 24,
                                      color: Color(0xFFB0B0B0),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Category Title
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),

                                  // Delete Button (Only in Edit Mode - assumed always true here)
                                  GestureDetector(
                                    onTap: () {
                                      Get.defaultDialog(
                                        title: '카테고리 삭제',
                                        titleStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        middleText:
                                            '"$category" 카테고리를 삭제하시겠습니까?',
                                        middleTextStyle: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        textConfirm: '삭제',
                                        textCancel: '취소',
                                        confirmTextColor: Colors.white,
                                        buttonColor: AppColors.primary,
                                        cancelTextColor:
                                            AppColors.textSecondary,
                                        onConfirm: () {
                                          controller.removePreferenceCategory(
                                            category,
                                          );
                                          Get.back();
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: Color(0xFF9D9D9D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Content
                          if (isExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  if (likesList.isNotEmpty ||
                                      dislikesList.isNotEmpty) ...[
                                    GestureDetector(
                                      onTap: () {
                                        _showPreferenceBottomSheet(
                                          context,
                                          controller,
                                          category: category,
                                          initialLikes: likesList,
                                          initialDislikes: dislikesList,
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          if (likesList.isNotEmpty)
                                            Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF2F80ED,
                                                  ), // Blue
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '선호',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2F80ED),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    likes,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textPrimary,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (dislikesList.isNotEmpty)
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF333333,
                                                  ), // Dark Gray
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '비선호',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF333333),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    dislikes,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textPrimary,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 16),

              // Add Preference Button
              _buildAddButton(
                label: '취향 기록 추가하기',
                onTap: () {
                  _showPreferenceBottomSheet(context, controller);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required Widget child,
    required VoidCallback onDelete,
    IconData? icon,
    VoidCallback? onIconTap,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                GestureDetector(
                  onTap: onIconTap,
                  child: Icon(icon, size: 16, color: const Color(0xFF999999)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(child: child),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(
            Icons.remove_circle_outline,
            size: 20,
            color: Color(0xFFD9D9D9),
          ),
        ),
      ],
    );
  }

  void _showPreferenceBottomSheet(
    BuildContext context,
    PersonEditController controller, {
    String? category,
    List<String>? initialLikes,
    List<String>? initialDislikes,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreferenceAddBottomSheet(
        initialCategory: category,
        initialLikes: initialLikes,
        initialDislikes: initialDislikes,
        onAdd: (cat, likes, dislikes) {
          if (category != null) {
            // Update existing
            controller.updatePreferenceGroup(category, cat, likes, dislikes);
          } else {
            // Add new
            controller.addPreferences(cat, likes, dislikes);
          }
          Get.back();
        },
      ),
    );
  }

  void _showAddCustomFieldDialog(
    BuildContext context,
    PersonEditController controller,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기본 정보 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '항목명 (예: 별명)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: '내용 (예: 가원)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                controller.addCustomField(
                  titleController.text,
                  contentController.text,
                );
                Get.back();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showBirthDatePicker(
    BuildContext context,
    PersonEditController controller,
  ) {
    DateTime selectedDate =
        controller.lunarBirthDate.value ??
        controller.birthDate.value ??
        DateTime.now();
    bool isLunar = controller.isLunarBirth.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 500,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('생년월일 선택', style: AppTextStyles.header2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTypeButton('양력', !isLunar, () {
                        setState(() => isLunar = false);
                      }),
                      const SizedBox(width: 10),
                      _buildTypeButton('음력', isLunar, () {
                        setState(() => isLunar = true);
                      }),
                    ],
                  ),
                  Expanded(
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateChanged: (date) {
                        setState(() => selectedDate = date);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.setBirthDate(selectedDate, isLunar);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Color(0xFF9D9D9D),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9D9D9D)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
