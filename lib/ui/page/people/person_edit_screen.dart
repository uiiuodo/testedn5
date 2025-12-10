import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_input_field.dart';
import '../../widgets/common/group_add_bottom_sheet.dart';
import '../../widgets/common/group_dropdown_menu.dart';
import 'person_edit_controller.dart';

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
                        decoration: const InputDecoration(
                          hintText: '이름 / 애칭 (필수)',
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF999999),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
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

                      showGroupDropdown(
                        context,
                        position: position,
                        groups: controller.groups,
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
                          controller.pickBirthDate(context);
                        },
                        onDelete: () {
                          controller.birthDate.value = null;
                          controller.showBirthDate.value = false;
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.pickBirthDate(context);
                              },
                              child: Obx(() {
                                final date = controller.birthDate.value;
                                return Text(
                                  date != null
                                      ? DateFormat('yyyy-MM-dd').format(date)
                                      : '선택해주세요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: date != null
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFCCCCCC),
                                  ),
                                );
                              }),
                            ),
                            Obx(() {
                              if (controller.birthDate.value != null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: controller.toggleLunar,
                                          child: Row(
                                            children: [
                                              Icon(
                                                controller.isLunar.value
                                                    ? Icons.check_box
                                                    : Icons
                                                          .check_box_outline_blank,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                '음력으로 변경',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF666666),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          controller.koreanAge.value,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
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
              GestureDetector(
                onTap: () {
                  _showAddCustomFieldDialog(context, controller);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEBEBEB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+ 기본 정보 추가',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
                      controller.isAddingAnniversary.toggle();
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

              // Inline Add Anniversary
              Obx(() {
                if (controller.isAddingAnniversary.value) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFDEDEDE)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    controller.newAnniversaryTitleController,
                                decoration: const InputDecoration(
                                  hintText: '기념일 이름',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      controller.newAnniversaryDate.value,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  controller.newAnniversaryDate.value = date;
                                }
                              },
                              child: Obx(
                                () => Text(
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(controller.newAnniversaryDate.value),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              if (controller
                                  .newAnniversaryTitleController
                                  .text
                                  .isNotEmpty) {
                                controller.addAnniversary(
                                  controller.newAnniversaryTitleController.text,
                                  controller.newAnniversaryDate.value,
                                );
                                controller.newAnniversaryTitleController
                                    .clear();
                                controller.isAddingAnniversary.value = false;
                              }
                            },
                            child: const Text(
                              '추가',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              Obx(
                () => Column(
                  children: controller.anniversaries.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final anniv = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final titleController = TextEditingController(
                                  text: anniv.title,
                                );
                                DateTime selectedDate = anniv.date;

                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('기념일 수정'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: titleController,
                                          decoration: const InputDecoration(
                                            labelText: '기념일 이름',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        StatefulBuilder(
                                          builder: (context, setState) {
                                            return GestureDetector(
                                              onTap: () async {
                                                final date =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate: selectedDate,
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime(2100),
                                                    );
                                                if (date != null) {
                                                  setState(() {
                                                    selectedDate = date;
                                                  });
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(selectedDate),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (titleController.text.isNotEmpty) {
                                            controller.updateAnniversary(
                                              index,
                                              titleController.text,
                                              selectedDate,
                                            );
                                            Get.back();
                                          }
                                        },
                                        child: const Text('저장'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    anniv.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(anniv.date),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              controller.removeAnniversary(index);
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
                  }).toList(),
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
                      if (controller.newMemoController.text.isNotEmpty) {
                        controller.addMemo(controller.newMemoController.text);
                      }
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
                  children: controller.memos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final memo = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
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
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.removeMemo(index);
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
                  }).toList(),
                ),
              ),
              // Add Memo Input (Card Style)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.newMemoController,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            controller.addMemo(value);
                          }
                        },
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2A2A2A),
                        ),
                        decoration: const InputDecoration(
                          hintText: '내용 입력하기',
                          hintStyle: TextStyle(
                            color: Color(0xFFC2C2C2),
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (controller.newMemoController.text.isNotEmpty) {
                          controller.addMemo(controller.newMemoController.text);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF414141),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '추가',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
              Obx(
                () => Column(
                  children: controller.preferences.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pref = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFEBEBEB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: pref.title,
                                  onChanged: (value) {
                                    controller.updatePreference(
                                      index,
                                      value,
                                      pref.like ?? '',
                                      pref.dislike ?? '',
                                    );
                                  },
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF404040),
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: '카테고리 (예: 음식)',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.removePreference(index);
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '선호: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00A6FF),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: pref.like,
                                  onChanged: (value) {
                                    controller.updatePreference(
                                      index,
                                      pref.title,
                                      value,
                                      pref.dislike ?? '',
                                    );
                                  },
                                  maxLines: null,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF464646),
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: '입력해주세요',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '비선호: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF5C5C),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: pref.dislike,
                                  onChanged: (value) {
                                    controller.updatePreference(
                                      index,
                                      pref.title,
                                      pref.like ?? '',
                                      value,
                                    );
                                  },
                                  maxLines: null,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF464646),
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: '입력해주세요',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Add Preference Button
              GestureDetector(
                onTap: () {
                  controller.addPreference('', '', '');
                },
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
                      children: const [
                        Icon(
                          Icons.add_circle_outline,
                          size: 16,
                          color: Color(0xFF9D9D9D),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '취향 기록 추가하기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
}
