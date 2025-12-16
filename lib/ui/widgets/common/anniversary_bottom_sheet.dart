import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'package:get/get.dart';

class AnniversaryBottomSheet extends StatefulWidget {
  final String? initialTitle;
  final DateTime? initialDate;
  final bool initialHasYear;
  final Function(String title, DateTime date, bool hasYear) onSave;
  final VoidCallback? onDelete;

  const AnniversaryBottomSheet({
    super.key,
    this.initialTitle,
    this.initialDate,
    this.initialHasYear = true,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AnniversaryBottomSheet> createState() => _AnniversaryBottomSheetState();
}

class _AnniversaryBottomSheetState extends State<AnniversaryBottomSheet> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late bool _hasYear;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedDate = widget.initialDate ?? DateTime.now();
    _hasYear = widget.initialHasYear;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
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
            widget.initialTitle == null ? '기념일 추가' : '기념일 수정',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Year Toggle
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _hasYear = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _hasYear ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _hasYear
                          ? AppColors.primary
                          : const Color(0xFFDEDEDE),
                    ),
                  ),
                  child: Text(
                    '연도 포함',
                    style: TextStyle(
                      fontSize: 11,
                      color: _hasYear ? Colors.white : const Color(0xFF999999),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _hasYear = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: !_hasYear ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: !_hasYear
                          ? AppColors.primary
                          : const Color(0xFFDEDEDE),
                    ),
                  ),
                  child: Text(
                    '연도 없음',
                    style: TextStyle(
                      fontSize: 11,
                      color: !_hasYear ? Colors.white : const Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '기념일 이름',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Picker Trigger
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _hasYear
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate)
                    : DateFormat('MM-dd').format(_selectedDate),
                style: const TextStyle(fontSize: 16, color: Color(0xFF2A2A2A)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              if (widget.onDelete != null)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.onDelete!();
                      Get.back();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('삭제'),
                  ),
                ),
              if (widget.onDelete != null) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      widget.onSave(
                        _titleController.text,
                        _selectedDate,
                        _hasYear,
                      );
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
