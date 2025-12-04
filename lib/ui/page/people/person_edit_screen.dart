import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_input_field.dart';
import 'person_edit_controller.dart';

class PersonEditScreen extends StatelessWidget {
  final String? personId;

  const PersonEditScreen({super.key, this.personId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PersonEditController(personId: personId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: personId == null ? '사람 추가' : '사람 수정',
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '이름 / 애칭',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF999999),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(필수)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomInputField(
                          controller: controller.nameController,
                          hint: '이름 또는 애칭을 입력해주세요',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Group Selection (Moved to top right)
                  GestureDetector(
                    onTap: () {
                      _showGroupSelectionDialog(context, controller);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '그룹 설정',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDEDEDE)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Obx(() {
                                final groupId =
                                    controller.selectedGroupId.value;
                                final group = controller.groups
                                    .firstWhereOrNull((g) => g.id == groupId);
                                return Text(
                                  group?.name ?? '선택',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: group != null
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFCCCCCC),
                                  ),
                                );
                              }),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: Color(0xFF999999),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Info Fields (Deletable)
              Obx(() {
                if (!controller.showBirthDate.value)
                  return const SizedBox.shrink();
                return _buildDeletableInfoRow(
                  label: '생년월일',
                  onDelete: () {
                    controller.showBirthDate.value = false;
                    controller.birthDate.value = null;
                  },
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.birthDate.value ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        controller.birthDate.value = date;
                      }
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
                );
              }),
              Obx(() {
                if (!controller.showPhone.value) return const SizedBox.shrink();
                return _buildDeletableInfoRow(
                  label: '전화번호',
                  onDelete: () {
                    controller.showPhone.value = false;
                    controller.phoneController.clear();
                  },
                  child: CustomInputField(
                    controller: controller.phoneController,
                    hint: '입력해주세요',
                    keyboardType: TextInputType.phone,
                  ),
                );
              }),
              Obx(() {
                if (!controller.showAddress.value)
                  return const SizedBox.shrink();
                return _buildDeletableInfoRow(
                  label: '주소',
                  onDelete: () {
                    controller.showAddress.value = false;
                    controller.addressController.clear();
                  },
                  child: CustomInputField(
                    controller: controller.addressController,
                    hint: '입력해주세요',
                  ),
                );
              }),
              Obx(() {
                if (!controller.showEmail.value) return const SizedBox.shrink();
                return _buildDeletableInfoRow(
                  label: 'e-mail',
                  onDelete: () {
                    controller.showEmail.value = false;
                    controller.emailController.clear();
                  },
                  child: CustomInputField(
                    controller: controller.emailController,
                    hint: '입력해주세요',
                    keyboardType: TextInputType.emailAddress,
                  ),
                );
              }),

              // Add Information Button
              Obx(() {
                final hasHiddenFields =
                    !controller.showBirthDate.value ||
                    !controller.showPhone.value ||
                    !controller.showAddress.value ||
                    !controller.showEmail.value;

                if (!hasHiddenFields) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'birthDate':
                          controller.showBirthDate.value = true;
                          break;
                        case 'phone':
                          controller.showPhone.value = true;
                          break;
                        case 'address':
                          controller.showAddress.value = true;
                          break;
                        case 'email':
                          controller.showEmail.value = true;
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!controller.showBirthDate.value)
                        const PopupMenuItem(
                          value: 'birthDate',
                          child: Text('생년월일 추가'),
                        ),
                      if (!controller.showPhone.value)
                        const PopupMenuItem(
                          value: 'phone',
                          child: Text('전화번호 추가'),
                        ),
                      if (!controller.showAddress.value)
                        const PopupMenuItem(
                          value: 'address',
                          child: Text('주소 추가'),
                        ),
                      if (!controller.showEmail.value)
                        const PopupMenuItem(
                          value: 'email',
                          child: Text('e-mail 추가'),
                        ),
                    ],
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add_circle_outline,
                          size: 16,
                          color: Color(0xFF9D9D9D),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '정보 추가하기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),

              // 3. Anniversary Section
              Row(
                children: [
                  const Text(
                    '기념일',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      controller.isAddingAnniversary.toggle();
                    },
                    child: const Icon(
                      Icons.add_circle_outline,
                      size: 16,
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
                        vertical: 10,
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
                                // Edit Anniversary Dialog
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
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    color: const Color(0xFFB0B0B0),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '메모',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
                        vertical: 8,
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
              // Add Memo Input
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
                                      pref.like,
                                      pref.dislike,
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
                                      pref.dislike,
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
                                  color: Color(0xFF979797),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: pref.dislike,
                                  onChanged: (value) {
                                    controller.updatePreference(
                                      index,
                                      pref.title,
                                      pref.like,
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

              GestureDetector(
                onTap: () {
                  controller.addPreference('', '', '');
                },
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 14, color: Color(0xFF656565)),
                    SizedBox(width: 4),
                    Text(
                      '취향 추가하기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF656565),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletableInfoRow({
    required String label,
    required Widget child,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999),
              ),
            ),
          ),
          Expanded(child: child),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 16,
              color: Color(0xFF4A4A4A),
            ),
            onPressed: () {
              // TODO: Implement remove field logic
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showGroupSelectionDialog(
    BuildContext context,
    PersonEditController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 선택'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.groups
                .map(
                  (group) => RadioListTile(
                    title: Text(group.name),
                    value: group.id,
                    groupValue: controller.selectedGroupId.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedGroupId.value = value;
                        Get.back();
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
