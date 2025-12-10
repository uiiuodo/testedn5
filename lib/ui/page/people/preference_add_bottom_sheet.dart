import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';

import '../../widgets/common/custom_input_field.dart';

class PreferenceAddBottomSheet extends StatefulWidget {
  /// 처음 등록할 때는 null로 두고,
  /// 수정 모달로 띄울 때만 값 넣어서 호출하면 됨.
  final String? initialCategory; // 초기 카테고리 (예: "음식")
  final bool? initialIsLike; // 초기 선호 여부 (true=선호, false=비선호)
  final List<String>? initialContents; // 초기 내용 목록

  final Function(String category, bool isLike, List<String> contents) onAdd;

  const PreferenceAddBottomSheet({
    super.key,
    this.initialCategory,
    this.initialIsLike,
    this.initialContents,
    required this.onAdd,
  });

  @override
  State<PreferenceAddBottomSheet> createState() =>
      _PreferenceAddBottomSheetState();
}

class _PreferenceAddBottomSheetState extends State<PreferenceAddBottomSheet> {
  late TextEditingController _categoryController;
  late TextEditingController _contentController;

  // true: Like, false: Dislike, null: Not selected
  bool? _isLike;

  @override
  void initState() {
    super.initState();

    // 선호/비선호 초기값
    _isLike = widget.initialIsLike;

    // 카테고리 초기값
    _categoryController = TextEditingController(
      text: widget.initialCategory ?? '',
    );

    // 내용 초기값
    String initialText;

    if (widget.initialContents != null && widget.initialContents!.isNotEmpty) {
      // 이미 저장된 내용이 있을 때 → 각 줄 앞에 점 붙여서 보여주기
      initialText = widget.initialContents!.map((e) => '• $e').join('\n');
    } else {
      // 새로 추가할 때 → 첫 줄에 점 하나 깔아두기
      initialText = '• ';
    }

    _contentController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleContentChange(String value) {
    // 엔터 치면 자동으로 다음 줄에 점 찍어주기
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

    // 내용 파싱해서 깔끔한 리스트 만들기
    final rawLines = _contentController.text.split('\n');
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
                            ? const Color(0xFF2F80ED) // Blue (선호 선택)
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
                        color: const Color(0xFF333333),
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
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isLike == false
                            ? const Color(0xFF000000) // Black (비선호 선택)
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
                        color: const Color(0xFF333333),
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
                backgroundColor: const Color(0xFF2A2A2A),
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
