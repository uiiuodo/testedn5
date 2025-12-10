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
  final RxBool isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyRecord();
  }

  void loadMyRecord() {
    var me = _personRepository.getPerson(myId);
    if (me == null) {
      // Create default "Me" person if not exists
      me = Person(
        id: myId,
        name: '나', // Default name
        groupId: '', // No group initially
        birthDate: DateTime(1996, 8, 30), // Default for demo
      );
      _personRepository.addPerson(me);
    }
    person.value = me;
  }

  void toggleEditMode() {
    if (isEditMode.value) {
      saveMyRecord();
    } else {
      isEditMode.value = true;
    }
  }

  Future<void> saveMyRecord() async {
    if (person.value == null) return;
    try {
      await _personRepository.updatePerson(person.value!);
      isEditMode.value = false;
      Get.snackbar(
        '저장 완료',
        '나에 대한 기록이 저장되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
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
    if (person.value == null) return;
    // Since Person is immutable (or should be treated as such for Rx), we create a new instance
    // But Person class doesn't have copyWith. I should check if I can modify it or create a new one manually.
    // The Person class in the viewed file DOES NOT have copyWith.
    // I will manually create a new Person with updated fields.

    final p = person.value!;
    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: newDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: p.anniversaries,
      memos: p.memos,
      preferences: p.preferences,
    );
  }

  // Anniversaries
  void addAnniversary(String title, DateTime date, bool hasYear) {
    if (person.value == null) return;
    final newAnniv = Anniversary(
      id: const Uuid().v4(),
      personId: myId,
      title: title,
      date: date,
      type: AnniversaryType.etc,
      hasYear: hasYear,
    );
    final p = person.value!;
    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: [...p.anniversaries, newAnniv],
      memos: p.memos,
      preferences: p.preferences,
    );
  }

  void updateAnniversary(String id, String title, DateTime date, bool hasYear) {
    if (person.value == null) return;
    final p = person.value!;
    final updatedList = p.anniversaries.map((a) {
      if (a.id == id) {
        return Anniversary(
          id: a.id,
          personId: a.personId,
          title: title,
          date: date,
          type: a.type,
          hasYear: hasYear,
        );
      }
      return a;
    }).toList();

    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: updatedList,
      memos: p.memos,
      preferences: p.preferences,
    );
  }

  void deleteAnniversary(String id) {
    if (person.value == null) return;
    final p = person.value!;
    final updatedList = p.anniversaries.where((a) => a.id != id).toList();
    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: updatedList,
      memos: p.memos,
      preferences: p.preferences,
    );
  }

  // Memos
  void addMemo(String content) {
    if (person.value == null) return;
    final newMemo = Memo(
      id: const Uuid().v4(),
      personId: myId,
      content: content,
      createdAt: DateTime.now(),
    );
    final p = person.value!;
    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: p.anniversaries,
      memos: [...p.memos, newMemo],
      preferences: p.preferences,
    );
  }

  void updateMemo(String id, String content) {
    if (person.value == null) return;
    final p = person.value!;
    final updatedList = p.memos.map((m) {
      if (m.id == id) {
        return Memo(
          id: m.id,
          personId: m.personId,
          content: content,
          createdAt: m.createdAt,
        );
      }
      return m;
    }).toList();

    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: p.anniversaries,
      memos: updatedList,
      preferences: p.preferences,
    );
  }

  void deleteMemo(String id) {
    if (person.value == null) return;
    final p = person.value!;
    final updatedList = p.memos.where((m) => m.id != id).toList();
    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: p.anniversaries,
      memos: updatedList,
      preferences: p.preferences,
    );
  }

  // Preferences
  void updatePreference(String category, bool isLike, List<String> contents) {
    if (person.value == null) return;
    final p = person.value!;

    final currentPrefs = List<PreferenceCategory>.from(p.preferences);

    // Remove old ones matching category and type
    currentPrefs.removeWhere(
      (p) =>
          p.title == category && (isLike ? p.like != null : p.dislike != null),
    );

    // Add new ones
    for (var content in contents) {
      currentPrefs.add(
        PreferenceCategory(
          id: const Uuid().v4(),
          personId: myId,
          title: category,
          like: isLike ? content : null,
          dislike: !isLike ? content : null,
        ),
      );
    }

    person.value = Person(
      id: p.id,
      name: p.name,
      birthDate: p.birthDate,
      phone: p.phone,
      address: p.address,
      email: p.email,
      groupId: p.groupId,
      anniversaries: p.anniversaries,
      memos: p.memos,
      preferences: currentPrefs,
    );
  }
}
