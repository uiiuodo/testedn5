import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/model/person.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';
import '../../../data/model/preference_category.dart';
import '../../../data/repository/person_repository.dart';

class MyRecordController extends GetxController {
  final PersonRepository _personRepository = PersonRepository();
  static const String myId = 'me';

  final Rx<Person?> person = Rx<Person?>(null);
  // Mode State
  final RxBool isEditMode = false.obs;
  // Delete Mode logic is merged into Edit Mode behavior or separate if needed.
  // Requirement says: View Mode (Pencil) vs Edit Mode (Save).
  // We can keep isDeleteMode for granular deletions inside Edit Mode?
  // Let's assume Edit Mode enables all editing, including deletion.
  // But user request specifically mentions "View/Edit Mode" toggle.

  // We will use isEditMode for general editing state.
  // And existing isDeleteMode can be used for showing 'X' buttons within lists if we want to keep it separate or auto-enable it in Edit Mode.
  // Let's rely on isEditMode for enabling interactions.

  // Editable Fields
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxList<Anniversary> anniversaries = <Anniversary>[].obs;
  final RxList<Memo> memos = <Memo>[].obs;
  final RxList<PreferenceCategory> preferences = <PreferenceCategory>[].obs;

  // UI State
  final RxSet<String> expandedCategories = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyRecord();
  }

  Future<void> loadMyRecord() async {
    isEditMode.value = false; // Start in View Mode
    var me = await _personRepository.getPerson(myId);
    if (me == null) {
      // Create default "Me" person if not exists
      me = Person(
        id: myId,
        name: '나', // Default name
        groupId: '', // No group initially
        birthDate: null, // [Fix 1] Default to null (empty)
      );
      await _personRepository.addPerson(me);
    }
    person.value = me;

    // Initialize editable fields
    birthDate.value = me.birthDate;
    anniversaries.assignAll(me.anniversaries);
    memos.assignAll(me.memos);
    preferences.assignAll(me.preferences);

    // Initialize expanded categories
    final categories = me.preferences.map((e) => e.title).toSet();
    expandedCategories.assignAll(categories);
  }

  void toggleEditMode() {
    if (isEditMode.value) {
      // If canceling edit mode, reload original data?
      // Or just switch flag. Standard is usually "Save" or "Cancel".
      // User request: Pencil -> Edit Mode (shows Save button).
      // Save -> Saves and returns to View Mode.
      // So toggleEditMode here is mainly entering Edit Mode.
      // We might need a "cancel" or just assume saving is the only exit?
      // Request doesn't specify cancel. Just "View -> Edit -> Save -> View".
      // Let's implement entering edit mode.
      isEditMode.value = true;
    } else {
      isEditMode.value = true;
    }
  }

  Future<void> saveMyRecord() async {
    if (person.value == null) return;

    try {
      final updatedPerson = Person(
        id: person.value!.id,
        name: person.value!.name,
        birthDate: birthDate.value,
        phone: person.value!.phone,
        address: person.value!.address,
        email: person.value!.email,
        groupId: person.value!.groupId,
        anniversaries: anniversaries,
        memos: memos,
        preferences: preferences,
      );

      await _personRepository.updatePerson(updatedPerson);
      person.value = updatedPerson;

      // [Fix 2] Return to View Mode on success
      isEditMode.value = false;

      Get.snackbar(
        '저장 완료',
        '나에 대한 기록이 저장되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      // Keep Edit Mode on failure
      Get.snackbar(
        '저장 실패',
        '저장에 문제가 발생했습니다. 다시 시도해 주세요',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  // --- Update Methods ---

  void updateBirthDate(DateTime newDate) {
    birthDate.value = newDate;
  }

  // Anniversaries
  void addAnniversary(String title, DateTime date, bool hasYear) {
    anniversaries.add(
      Anniversary(
        id: const Uuid().v4(),
        personId: myId,
        title: title,
        date: date,
        type: AnniversaryType.etc,
        hasYear: hasYear,
      ),
    );
  }

  void addEmptyAnniversary() {
    anniversaries.add(
      Anniversary(
        id: const Uuid().v4(),
        personId: myId,
        title: '',
        date: DateTime.now(),
        type: AnniversaryType.etc,
        hasYear: true,
      ),
    );
  }

  void updateAnniversary(int index, String title, DateTime date, bool hasYear) {
    if (index < 0 || index >= anniversaries.length) return;
    final oldAnniv = anniversaries[index];
    anniversaries[index] = Anniversary(
      id: oldAnniv.id,
      personId: oldAnniv.personId,
      title: title,
      date: date,
      type: oldAnniv.type,
      hasYear: hasYear,
    );
  }

  void removeAnniversaryAt(int index) {
    if (index >= 0 && index < anniversaries.length) {
      anniversaries.removeAt(index);
    }
  }

  // Memos
  void addMemo(String content) {
    memos.add(
      Memo(
        id: const Uuid().v4(),
        personId: myId,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addEmptyMemo() {
    memos.add(
      Memo(
        id: const Uuid().v4(),
        personId: myId,
        content: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateMemo(int index, String content) {
    if (index < 0 || index >= memos.length) return;
    final oldMemo = memos[index];
    memos[index] = Memo(
      id: oldMemo.id,
      personId: oldMemo.personId,
      content: content,
      createdAt: oldMemo.createdAt,
    );
  }

  void removeMemoAt(int index) {
    if (index >= 0 && index < memos.length) {
      memos.removeAt(index);
    }
  }

  // Preferences
  void toggleCategoryExpansion(String category) {
    if (expandedCategories.contains(category)) {
      expandedCategories.remove(category);
    } else {
      expandedCategories.add(category);
    }
  }

  void removePreferenceCategory(String category) {
    preferences.removeWhere((p) => p.title == category);
    expandedCategories.remove(category);
  }

  void addPreferences(
    String category,
    List<String> likes,
    List<String> dislikes,
  ) {
    for (final content in likes) {
      preferences.add(
        PreferenceCategory(
          id: const Uuid().v4(),
          personId: myId,
          title: category,
          like: content,
          dislike: null,
        ),
      );
    }
    for (final content in dislikes) {
      preferences.add(
        PreferenceCategory(
          id: const Uuid().v4(),
          personId: myId,
          title: category,
          like: null,
          dislike: content,
        ),
      );
    }
  }

  void updatePreferenceGroup(
    String oldCategory,
    String newCategory,
    List<String> newLikes,
    List<String> newDislikes,
  ) {
    // 1. Remove ALL items matching oldCategory (both likes and dislikes)
    preferences.removeWhere((p) => p.title == oldCategory);

    // 2. Add new items
    addPreferences(newCategory, newLikes, newDislikes);

    // 3. Update expanded categories if category name changed
    if (oldCategory != newCategory) {
      if (expandedCategories.contains(oldCategory)) {
        expandedCategories.remove(oldCategory);
        expandedCategories.add(newCategory);
      }
    } else {
      // Ensure it stays expanded if it was expanded
      if (!expandedCategories.contains(newCategory)) {
        expandedCategories.add(newCategory);
      }
    }
  }
}
