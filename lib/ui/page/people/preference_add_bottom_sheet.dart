import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import '../../widgets/common/custom_input_field.dart';

class PreferenceAddBottomSheet extends StatefulWidget {
  /// 처음 등록할 때는 null로 두고,
  /// 수정 모달로 띄울 때만 값 넣어서 호출하면 됨.
  final String? initialCategory; // 초기 카테고리 (예: "음식")
  final List<String>? initialLikes; // 초기 선호 내용 목록
  final List<String>? initialDislikes; // 초기 비선호 내용 목록

  final Function(String category, List<String> likes, List<String> dislikes)
  onAdd;

  const PreferenceAddBottomSheet({
    super.key,
    this.initialCategory,
    this.initialLikes,
    this.initialDislikes,
    required this.onAdd,
  });

  @override
  State<PreferenceAddBottomSheet> createState() =>
      _PreferenceAddBottomSheetState();
}

class _PreferenceAddBottomSheetState extends State<PreferenceAddBottomSheet> {
  late TextEditingController _categoryController;
  late TextEditingController _likeController;
  late TextEditingController _dislikeController;

  bool isLikeEnabled = false;
  bool isDislikeEnabled = false;

  @override
  void initState() {
    super.initState();

    // 카테고리 초기값
    _categoryController = TextEditingController(
      text: widget.initialCategory ?? '',
    );

    // 선호 초기값
    final likes = widget.initialLikes ?? [];
    isLikeEnabled = likes.isNotEmpty;
    _likeController = TextEditingController(text: _formatContents(likes));

    // 비선호 초기값
    final dislikes = widget.initialDislikes ?? [];
    isDislikeEnabled = dislikes.isNotEmpty;
    _dislikeController = TextEditingController(text: _formatContents(dislikes));

    // 새로 추가 모드일 때 기본적으로 둘 다 꺼져있음 (위 로직에서 처리됨)
  }

  String _formatContents(List<String> contents) {
    if (contents.isEmpty) return '• ';
    return contents.map((e) => '• $e').join('\n');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _likeController.dispose();
    _dislikeController.dispose();
    super.dispose();
  }

  void _handleContentChange(TextEditingController controller, String value) {
    // 엔터 치면 자동으로 다음 줄에 점 찍어주기
    if (value.endsWith('\n')) {
      final newValue = '$value• ';
      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  List<String> _parseContents(String text) {
    final rawLines = text.split('\n');
    final validContents = <String>[];

    for (final line in rawLines) {
      var cleanLine = line.trim();

      if (cleanLine.startsWith('•')) {
        cleanLine = cleanLine.substring(1).trim();
      } else if (cleanLine.startsWith('·')) {
        cleanLine = cleanLine.substring(1).trim();
      }

      if (cleanLine.isNotEmpty) {
        validContents.add(cleanLine);
      }
    }
    return validContents;
  }

  void _submit() {
    final category = _categoryController.text.trim();
    if (category.isEmpty) {
      Get.snackbar('알림', '카테고리를 입력해주세요.');
      return;
    }

    final likes = isLikeEnabled
        ? _parseContents(_likeController.text)
        : <String>[];
    final dislikes = isDislikeEnabled
        ? _parseContents(_dislikeController.text)
        : <String>[];

    if (likes.isEmpty && dislikes.isEmpty) {
      Get.snackbar('알림', '선호 또는 비선호 중 하나 이상 내용을 입력해주세요.');
      return;
    }

    widget.onAdd(category, likes, dislikes);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialCategory != null;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? '취향 기록 수정' : '취향 기록',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Category
          CustomInputField(
            controller: _categoryController,
            label: '카테고리 (예: 음식)',
            hint: '입력해주세요',
          ),
          const SizedBox(height: 20),

          // Like Section
          _buildSection(
            label: '선호',
            isEnabled: isLikeEnabled,
            controller: _likeController,
            onToggle: () {
              setState(() {
                isLikeEnabled = !isLikeEnabled;
              });
            },
            hintText: '• 예: 연어\n• 예: 명란',
          ),
          const SizedBox(height: 20),

          // Dislike Section
          _buildSection(
            label: '비선호',
            isEnabled: isDislikeEnabled,
            controller: _dislikeController,
            onToggle: () {
              setState(() {
                isDislikeEnabled = !isDislikeEnabled;
              });
            },
            hintText: '• 예: 오이\n• 예: 당근',
          ),
          const SizedBox(height: 30),

          // Add Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditMode ? '수정하기' : '추가하기',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required bool isEnabled,
    required TextEditingController controller,
    required VoidCallback onToggle,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isEnabled) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: AppTextStyles.body2,
              onChanged: (val) => _handleContentChange(controller, val),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
