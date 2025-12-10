import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';

import '../../widgets/common/custom_input_field.dart';

class PreferenceAddBottomSheet extends StatefulWidget {
  final Function(String category, bool isLike, List<String> contents) onAdd;

  const PreferenceAddBottomSheet({super.key, required this.onAdd});

  @override
  State<PreferenceAddBottomSheet> createState() =>
      _PreferenceAddBottomSheetState();
}

class _PreferenceAddBottomSheetState extends State<PreferenceAddBottomSheet> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // true: Like, false: Dislike, null: Not selected
  bool? _isLike;

  @override
  void initState() {
    super.initState();
    // Start with a bullet point
    _contentController.text = '• ';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleContentChange(String value) {
    // Simple auto-bullet logic
    // If the user just pressed enter (newline), add a bullet
    if (value.endsWith('\n')) {
      final newValue = '$value• ';
      _contentController.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  void _submit() {
    final category = _categoryController.text.trim();
    if (category.isEmpty) {
      Get.snackbar('알림', '카테고리를 입력해주세요.');
      return;
    }

    if (_isLike == null) {
      Get.snackbar('알림', '선호/비선호를 선택해주세요.');
      return;
    }

    // Parse content
    final rawLines = _contentController.text.split('\n');
    final validContents = <String>[];

    for (final line in rawLines) {
      // Remove leading bullet and whitespace
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

    if (validContents.isEmpty) {
      Get.snackbar('알림', '내용을 입력해주세요.');
      return;
    }

    widget.onAdd(category, _isLike!, validContents);
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '취향 기록',
            style: TextStyle(
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

          // Type Selection (Like / Dislike)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLike = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7), // Very Light Gray
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isLike == true
                            ? const Color(0xFF2F80ED) // Blue
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '선호',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _isLike == true
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: const Color(0xFF333333), // Dark Gray
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLike = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7), // Very Light Gray
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isLike == false
                            ? const Color(0xFF000000) // Black
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '비선호',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _isLike == false
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: const Color(0xFF333333), // Dark Gray
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content Input
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              controller: _contentController,
              onChanged: _handleContentChange,
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.textPrimary,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: '내용 입력하기',
                hintStyle: TextStyle(color: Color(0xFF999999)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Add Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A), // Black
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '추가하기',
                style: TextStyle(
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
}
