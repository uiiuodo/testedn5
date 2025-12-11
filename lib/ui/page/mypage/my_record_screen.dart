import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'my_record_controller.dart';
import '../people/preference_add_bottom_sheet.dart';
import '../../widgets/common/anniversary_bottom_sheet.dart';
import '../../widgets/common/memo_bottom_sheet.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';
import '../../theme/app_colors.dart';

class MyRecordScreen extends StatelessWidget {
  const MyRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRecordController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Pen Icon: Toggle Delete Mode
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: controller.isDeleteMode.value
                    ? AppColors.primary
                    : Colors.black,
              ),
              onPressed: controller.toggleDeleteMode,
            ),
          ),
          // Check Icon: Save
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: controller.saveMyRecord,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.person.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                '나에 대한 기록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(height: 24),

              // Basic Info (BirthDate)
              Row(
                children: [
                  const Text(
                    '생년월일',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF919191),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.birthDate.value ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        controller.updateBirthDate(date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        controller.birthDate.value != null
                            ? '${DateFormat('yyyy.MM.dd').format(controller.birthDate.value!)} ${_calculateAge(controller.birthDate.value!)}'
                            : '입력해주세요',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFDEDEDE)),
              const SizedBox(height: 24),

              // Anniversaries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    '기념일',
                    iconColor: const Color(0xFFB0B0B0),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showAnniversaryBottomSheet(context, controller),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                              if (controller.isDeleteMode.value)
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
              const SizedBox(height: 30),

              // Memos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('메모', iconColor: const Color(0xFFB0B0B0)),
                  GestureDetector(
                    onTap: () => controller.addEmptyMemo(),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                          if (controller.isDeleteMode.value)
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

              // Preferences
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    '취향 기록',
                    iconColor: const Color(0xFFB0B0B0),
                  ),
                  GestureDetector(
                    onTap: () => _showPreferenceBottomSheet(
                      context,
                      controller,
                      category: '',
                      isLike: true,
                      initialContents: [],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPreferenceList(context, controller),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    int manAge = age;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      manAge--;
    }
    int koreanAge = age + 1;
    return '(${koreanAge}세, 만 ${manAge}세)';
  }

  Widget _buildSectionHeader(String title, {required Color iconColor}) {
    return Row(
      children: [
        Container(width: 9, height: 9, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9D9D9D),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceList(
    BuildContext context,
    MyRecordController controller,
  ) {
    return Obx(() {
      final grouped = <String, List<dynamic>>{};
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

          final likesStr = likesList.join(', ');
          final dislikesStr = dislikesList.join(', ');

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPreferenceAccordion(
              context: context,
              controller: controller,
              title: category,
              likes: likesStr,
              dislikes: dislikesStr,
              likesList: likesList.cast<String>(),
              dislikesList: dislikesList.cast<String>(),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPreferenceAccordion({
    required BuildContext context,
    required MyRecordController controller,
    required String title,
    required String likes,
    required String dislikes,
    required List<String> likesList,
    required List<String> dislikesList,
  }) {
    final isExpanded = controller.expandedCategories.contains(title);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => controller.toggleCategoryExpansion(title),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.transparent,
              child: Row(
                children: [
                  Transform.rotate(
                    angle: isExpanded ? 3.14 / 2 : 0,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF9D9D9D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF404040),
                    ),
                  ),
                  const Spacer(),
                  if (controller.isDeleteMode.value)
                    GestureDetector(
                      onTap: () {
                        Get.defaultDialog(
                          title: '카테고리 삭제',
                          middleText: '이 카테고리의 모든 취향 기록이 삭제됩니다.\n계속하시겠습니까?',
                          textConfirm: '삭제',
                          textCancel: '취소',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            controller.removePreferenceCategory(title);
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
                  if (likesList.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PreferenceAddBottomSheet(
                            initialCategory: title,
                            initialIsLike: true,
                            initialContents: likesList,
                            onAdd: (newCategory, newIsLike, newContents) {
                              controller.updatePreferenceGroup(
                                title,
                                true,
                                newCategory,
                                newIsLike,
                                newContents,
                              );
                              Get.back();
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2F80ED), // Blue
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '선호',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F80ED),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              likes,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (dislikesList.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PreferenceAddBottomSheet(
                            initialCategory: title,
                            initialIsLike: false,
                            initialContents: dislikesList,
                            onAdd: (newCategory, newIsLike, newContents) {
                              controller.updatePreferenceGroup(
                                title,
                                false,
                                newCategory,
                                newIsLike,
                                newContents,
                              );
                              Get.back();
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF333333), // Dark Gray
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '비선호',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dislikes,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
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
  }

  // --- Dialogs / BottomSheets ---

  void _showAnniversaryBottomSheet(
    BuildContext context,
    MyRecordController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnniversaryBottomSheet(
        onSave: (title, date, hasYear) {
          controller.addAnniversary(title, date, hasYear);
        },
      ),
    );
  }

  void _showPreferenceBottomSheet(
    BuildContext context,
    MyRecordController controller, {
    required String category,
    required bool isLike,
    required List<String> initialContents,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreferenceAddBottomSheet(
        initialCategory: category,
        initialIsLike: isLike,
        initialContents: initialContents,
        onAdd: (cat, like, contents) {
          controller.addPreferences(cat, like, contents);
          Get.back();
        },
      ),
    );
  }
}
