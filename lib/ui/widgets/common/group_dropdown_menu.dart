import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../data/model/group.dart';

Future<void> showGroupDropdown(
  BuildContext context, {
  required RelativeRect position,
  required List<Group> groups,
  required Function(Group) onGroupSelected,
  required VoidCallback onAddGroup,
}) async {
  final result = await showMenu<dynamic>(
    context: context,
    position: position,
    elevation: 4,
    shadowColor: Colors.black.withOpacity(
      0.5,
    ), // Match home screen shadow roughly
    color: const Color(0xFFFBFBFB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    items: [
      ...groups.map(
        (group) => PopupMenuItem<Group>(
          value: group,
          height: 36, // Compact height
          child: Text(
            group.name,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      const PopupMenuDivider(height: 1),
      PopupMenuItem<String>(
        value: 'add_group',
        height: 36,
        child: Text(
          '그룹 추가하기',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w300,
            color: AppColors.primary,
          ),
        ),
      ),
    ],
  );

  if (result != null) {
    if (result is Group) {
      onGroupSelected(result);
    } else if (result == 'add_group') {
      onAddGroup();
    }
  }
}
