import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/model/person.dart';
import '../calendar/person_calendar/person_calendar_screen.dart';
import '../calendar/person_calendar/person_calendar_controller.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';
import '../../../data/model/preference_category.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'person_detail_controller.dart';
import 'person_edit_screen.dart';
import '../../widgets/common/refreshable_layout.dart';

class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PersonDetailController(widget.personId),
      tag: widget.personId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () async {
              // Navigate to Edit Screen with personId
              await Get.to(() => PersonEditScreen(personId: widget.personId));
              // Refresh data on return
              await controller.loadPerson();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final person = controller.person.value;
          if (person == null)
            return const Center(child: CircularProgressIndicator());

          return RefreshableLayout(
            onRefresh: () async {
              await controller.loadPerson();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Basic Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDEDEDE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              person.name,
                              style: AppTextStyles.header2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          '생년월일',
                          _buildBirthdayText(person, controller),
                        ),
                        _buildInfoRow('전화번호', person.phone),
                        _buildInfoRow('주소', person.address),
                        _buildInfoRow('e-mail', person.email),
                        _buildInfoRow('MBTI', person.mbti),
                        ...person.extraInfo.entries.map(
                          (e) => _buildInfoRow(e.key, e.value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. Anniversaries
                  _buildSectionHeader('기념일'),
                  const SizedBox(height: 10),
                  Column(
                    children: person.anniversaries
                        .map((anniv) => _buildAnniversaryCard(anniv))
                        .toList(),
                  ),
                  const SizedBox(height: 30),

                  // 3. Memos
                  _buildSectionHeader('메모'),
                  const SizedBox(height: 10),
                  Column(
                    children: person.memos
                        .map((memo) => _buildMemoCard(memo))
                        .toList(),
                  ),
                  const SizedBox(height: 30),

                  // 4. Preferences
                  _buildSectionHeader('취향 기록'),
                  const SizedBox(height: 10),
                  _buildPreferenceList(person.preferences),
                  const SizedBox(height: 40),

                  // 6. Bottom Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const PersonCalendarScreen(),
                          binding: BindingsBuilder(() {
                            Get.put(
                              PersonCalendarController(
                                personId: widget.personId,
                              ),
                            );
                          }),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '이 사람과의 개인 캘린더로 이동',
                        style: AppTextStyles.button.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPreferenceList(List<PreferenceCategory> preferences) {
    final grouped = <String, List<PreferenceCategory>>{};
    for (var p in preferences) {
      if (!grouped.containsKey(p.title)) grouped[p.title] = [];
      grouped[p.title]!.add(p);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final title = entry.key;
        final prefs = entry.value;

        final likesList = prefs
            .where((p) => p.like != null && p.like!.isNotEmpty)
            .map((p) => p.like!)
            .toList();
        final dislikesList = prefs
            .where((p) => p.dislike != null && p.dislike!.isNotEmpty)
            .map((p) => p.dislike!)
            .toList();

        return _PreferenceAccordion(
          title: title,
          likes: likesList,
          dislikes: dislikesList,
        );
      }).toList(),
    );
  }

  String? _buildBirthdayText(Person person, PersonDetailController controller) {
    if (person.birthDate == null) return null;

    // Calculate International Age (Man Age)
    final age = _calculateInternationalAge(person.birthDate);
    final ageText = age != null ? ' (만 ${age}세)' : '';

    if (controller.isLunarBirth.value &&
        controller.lunarBirthDate.value != null) {
      return '음력 ${DateFormat('yyyy.MM.dd').format(controller.lunarBirthDate.value!)}$ageText';
    }
    return '${DateFormat('yyyy.MM.dd').format(person.birthDate!)}$ageText';
  }

  int? _calculateInternationalAge(DateTime? birthDate) {
    if (birthDate == null) return null;

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 9, height: 9, color: const Color(0xFFB0B0B0)),
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

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty || value == '-') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF919191)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A4A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnniversaryCard(Anniversary anniv) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            anniv.title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2A2A2A)),
          ),
          Text(
            anniv.hasYear
                ? DateFormat('yyyy.MM.dd').format(anniv.date)
                : DateFormat('MM.dd').format(anniv.date),
            style: const TextStyle(fontSize: 13, color: Color(0xFF2A2A2A)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard(Memo memo) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        memo.content,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2A2A2A),
          height: 1.4,
        ),
      ),
    );
  }
}

class _PreferenceAccordion extends StatefulWidget {
  final String title;
  final List<String> likes;
  final List<String> dislikes;

  const _PreferenceAccordion({
    required this.title,
    required this.likes,
    required this.dislikes,
  });

  @override
  State<_PreferenceAccordion> createState() => _PreferenceAccordionState();
}

class _PreferenceAccordionState extends State<_PreferenceAccordion> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            color: Colors.transparent, // Hit test
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF404040),
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: const Color(0xFFB0B0B0),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          if (widget.likes.isNotEmpty)
            _buildDetailBox('선호', widget.likes, const Color(0xFF00A6FF)),
          const SizedBox(height: 8),
          if (widget.dislikes.isNotEmpty)
            _buildDetailBox('비선호', widget.dislikes, const Color(0xFF979797)),
          const SizedBox(height: 16),
        ],
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDetailBox(String label, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF464646),
                  height: 1.4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
