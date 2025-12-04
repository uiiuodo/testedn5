import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/model/group.dart';
import '../../../data/repository/group_repository.dart';
import '../home/home_controller.dart';
import '../../widgets/primary_button.dart';

class GroupAddSheet extends StatefulWidget {
  const GroupAddSheet({super.key});

  @override
  State<GroupAddSheet> createState() => _GroupAddSheetState();
}

class _GroupAddSheetState extends State<GroupAddSheet> {
  final _nameController = TextEditingController();
  final GroupRepository _groupRepository = GroupRepository();

  // Pastel colors
  final List<int> _colors = [
    0xFFFFD1DC, // Pink
    0xFFFFF5BA, // Yellow
    0xFFD4F0F0, // Blue
    0xFFE0E0E0, // Grey
    0xFFE6E6FA, // Lavender
    0xFFFFE4E1, // MistyRose
    0xFFF0FFF0, // Honeydew
    0xFFF5F5DC, // Beige
  ];

  int _selectedColor = 0xFFFFD1DC;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '그룹 추가하기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '그룹 이름',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('색상 선택', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((colorValue) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = colorValue;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    shape: BoxShape.circle,
                    border: _selectedColor == colorValue
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                  child: _selectedColor == colorValue
                      ? const Icon(Icons.check, size: 20, color: Colors.black54)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '등록하기',
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final newGroup = Group(
                  id: const Uuid().v4(),
                  name: _nameController.text,
                  colorValue: _selectedColor,
                );
                await _groupRepository.addGroup(newGroup);

                // Refresh Home
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().fetchGroups();
                }

                Get.back();
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
