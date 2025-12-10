import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class GroupAddBottomSheet extends StatefulWidget {
  final Function(String name, int colorValue) onAdd;

  const GroupAddBottomSheet({super.key, required this.onAdd});

  @override
  State<GroupAddBottomSheet> createState() => _GroupAddBottomSheetState();
}

class _GroupAddBottomSheetState extends State<GroupAddBottomSheet> {
  final TextEditingController _groupNameController = TextEditingController();
  int _selectedColorValue = 0xFFFFE9E9; // Default color

  final List<int> _groupColors = [
    0xFFFFE9E9,
    0xFFFFECD7,
    0xFFFFF7C7,
    0xFFDFFFC7,
    0xFFD6FAFF,
    0xFFC0DCFF,
    0xFFEED3FF,
    0xFFD9D9D9,
  ];

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 51, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '그룹 추가하기',
            style: AppTextStyles.header2.copyWith(
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Group Name Input
          Container(
            height: 31,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.5),
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _groupNameController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: '그룹 이름 입력하기',
                hintStyle: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.primary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Color Selection
          Row(
            children: [
              Text(
                '컬러',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 12),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _groupColors.map((colorValue) {
              final isSelected = _selectedColorValue == colorValue;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorValue = colorValue;
                  });
                },
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 1)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 41,
            child: ElevatedButton(
              onPressed: () {
                if (_groupNameController.text.isNotEmpty) {
                  widget.onAdd(_groupNameController.text, _selectedColorValue);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.5),
                ),
                elevation: 0,
              ),
              child: const Text(
                '등록하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          // Add extra padding for keyboard if needed, or rely on modal bottom sheet behavior
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
          ),
        ],
      ),
    );
  }
}
