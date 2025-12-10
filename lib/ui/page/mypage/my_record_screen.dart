import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'my_record_controller.dart';
import '../people/preference_add_bottom_sheet.dart';
import '../../widgets/common/anniversary_bottom_sheet.dart';
import '../../widgets/common/memo_bottom_sheet.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';

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
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditMode.value ? Icons.check : Icons.edit_outlined,
                color: Colors.black,
              ),
              onPressed: controller.toggleEditMode,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final person = controller.person.value;
        if (person == null) {
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
                    onTap: controller.isEditMode.value
                        ? () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: person.birthDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              controller.updateBirthDate(date);
                            }
                          }
                        : null,
                    child: Container(
                      padding: controller.isEditMode.value
                          ? const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            )
                          : EdgeInsets.zero,
                      decoration: controller.isEditMode.value
                          ? BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(5),
                            )
                          : null,
                      child: Text(
                        person.birthDate != null
                            ? '${DateFormat('yyyy.MM.dd').format(person.birthDate!)} ${_calculateAge(person.birthDate!)}'
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
                  if (controller.isEditMode.value)
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
              ...person.anniversaries.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: controller.isEditMode.value
                        ? () => _showAnniversaryBottomSheet(
                            context,
                            controller,
                            anniversary: a,
                          )
                        : null,
                    child: _buildAnniversaryCard(
                      a.title,
                      a.hasYear
                          ? DateFormat('yyyy년 M월 d일').format(a.date)
                          : DateFormat('M월 d일').format(a.date),
                      isEditing: controller.isEditMode.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Memos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('메모', iconColor: const Color(0xFFB0B0B0)),
                  if (controller.isEditMode.value)
                    GestureDetector(
                      onTap: () => _showMemoBottomSheet(context, controller),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0xFF9D9D9D),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...person.memos.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: controller.isEditMode.value
                        ? () =>
                              _showMemoBottomSheet(context, controller, memo: m)
                        : null,
                    child: _buildMemoCard(
                      m.content,
                      isEditing: controller.isEditMode.value,
                    ),
                  ),
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
                  if (controller.isEditMode.value)
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
              ..._buildPreferenceList(context, controller),

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

  Widget _buildAnniversaryCard(
    String title,
    String date, {
    bool isEditing = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
        border: isEditing ? Border.all(color: const Color(0xFFDEDEDE)) : null,
      ),
      child: Row(
        children: [
          Text(
            '$title   ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A2A),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Color(0xFF2A2A2A),
            ),
          ),
          if (isEditing) ...[
            const Spacer(),
            const Icon(Icons.edit, size: 14, color: Color(0xFF9D9D9D)),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoCard(String content, {bool isEditing = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
        border: isEditing ? Border.all(color: const Color(0xFFDEDEDE)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Color(0xFF2A2A2A),
              height: 1.3,
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.edit, size: 14, color: Color(0xFF9D9D9D)),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPreferenceList(
    BuildContext context,
    MyRecordController controller,
  ) {
    final person = controller.person.value!;
    final grouped = <String, List<dynamic>>{};
    for (var p in person.preferences) {
      if (!grouped.containsKey(p.title)) grouped[p.title] = [];
      grouped[p.title]!.add(p);
    }

    return grouped.entries.map((entry) {
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
    }).toList();
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
    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF404040),
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Likes
              if (likes.isNotEmpty) ...[
                const Text(
                  '선호',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF00A6FF),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: controller.isEditMode.value
                      ? () => _showPreferenceBottomSheet(
                          context,
                          controller,
                          category: title,
                          isLike: true,
                          initialContents: likesList,
                        )
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2F80ED),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      likes,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF464646),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Dislikes
              if (dislikes.isNotEmpty) ...[
                const Text(
                  '비선호',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: controller.isEditMode.value
                      ? () => _showPreferenceBottomSheet(
                          context,
                          controller,
                          category: title,
                          isLike: false,
                          initialContents: dislikesList,
                        )
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      dislikes,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF464646),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- Dialogs / BottomSheets ---

  void _showAnniversaryBottomSheet(
    BuildContext context,
    MyRecordController controller, {
    Anniversary? anniversary,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnniversaryBottomSheet(
        initialTitle: anniversary?.title,
        initialDate: anniversary?.date,
        initialHasYear: anniversary?.hasYear ?? true,
        onSave: (title, date, hasYear) {
          if (anniversary == null) {
            controller.addAnniversary(title, date, hasYear);
          } else {
            controller.updateAnniversary(anniversary.id, title, date, hasYear);
          }
        },
        onDelete: anniversary != null
            ? () => controller.deleteAnniversary(anniversary.id)
            : null,
      ),
    );
  }

  void _showMemoBottomSheet(
    BuildContext context,
    MyRecordController controller, {
    Memo? memo,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemoBottomSheet(
        initialContent: memo?.content,
        onSave: (content) {
          if (memo == null) {
            controller.addMemo(content);
          } else {
            controller.updateMemo(memo.id, content);
          }
        },
        onDelete: memo != null ? () => controller.deleteMemo(memo.id) : null,
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
          controller.updatePreference(cat, like, contents);
          Get.back();
        },
      ),
    );
  }
}
