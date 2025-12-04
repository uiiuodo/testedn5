import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/model/person.dart';
import '../../../data/model/group.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';
import '../../../data/model/preference_category.dart';
import '../../../data/repository/person_repository.dart';
import '../../../data/repository/group_repository.dart';
import '../home/home_controller.dart';

class PersonEditController extends GetxController {
  final PersonRepository _personRepository = PersonRepository();
  final GroupRepository _groupRepository = GroupRepository();

  final String? personId;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxString selectedGroupId = ''.obs;

  // Visibility Flags
  final RxBool showBirthDate = false.obs;
  final RxBool showPhone = false.obs;
  final RxBool showAddress = false.obs;
  final RxBool showEmail = false.obs;

  final RxList<Anniversary> anniversaries = <Anniversary>[].obs;
  final RxList<Memo> memos = <Memo>[].obs;
  final RxList<PreferenceCategory> preferences = <PreferenceCategory>[].obs;

  final RxList<Group> groups = <Group>[].obs;

  // UI State for inline adding
  final RxBool isAddingAnniversary = false.obs;
  final Rx<DateTime> newAnniversaryDate = DateTime.now().obs;
  final newAnniversaryTitleController = TextEditingController();
  final newMemoController = TextEditingController();

  PersonEditController({this.personId});

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    if (personId != null) {
      loadPerson(personId!);
    }
  }

  void fetchGroups() {
    groups.value = _groupRepository.getGroups();
  }

  void addNewGroup(String name) async {
    // Generate a random color for the new group
    // Simple random color generation for now
    final int colorValue =
        (0xFF000000 + (DateTime.now().millisecondsSinceEpoch & 0xFFFFFF)) |
        0xFF000000;

    final newGroup = Group(
      id: const Uuid().v4(),
      name: name,
      colorValue: colorValue,
    );

    await _groupRepository.addGroup(newGroup);
    fetchGroups();
    selectedGroupId.value = newGroup.id;
  }

  void loadPerson(String id) {
    final person = _personRepository.getPerson(id);
    if (person != null) {
      nameController.text = person.name;
      phoneController.text = person.phone ?? '';
      addressController.text = person.address ?? '';
      emailController.text = person.email ?? '';
      birthDate.value = person.birthDate;
      selectedGroupId.value = person.groupId;
      anniversaries.value = List.from(person.anniversaries);
      memos.value = List.from(person.memos);
      preferences.value = List.from(person.preferences);

      // Set visibility flags based on data presence
      showBirthDate.value = person.birthDate != null;
      showPhone.value = person.phone != null && person.phone!.isNotEmpty;
      showAddress.value = person.address != null && person.address!.isNotEmpty;
      showEmail.value = person.email != null && person.email!.isNotEmpty;
    }
  }

  void savePerson() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('오류', '이름을 입력해주세요');
      return;
    }
    if (selectedGroupId.value.isEmpty) {
      Get.snackbar('오류', '그룹을 선택해주세요');
      return;
    }

    final newPerson = Person(
      id: personId ?? const Uuid().v4(),
      name: nameController.text,
      birthDate: showBirthDate.value ? birthDate.value : null,
      phone: showPhone.value && phoneController.text.isNotEmpty
          ? phoneController.text
          : null,
      address: showAddress.value && addressController.text.isNotEmpty
          ? addressController.text
          : null,
      email: showEmail.value && emailController.text.isNotEmpty
          ? emailController.text
          : null,
      groupId: selectedGroupId.value,
      anniversaries: anniversaries,
      memos: memos,
      preferences: preferences,
    );

    if (personId != null) {
      await _personRepository.updatePerson(newPerson);
    } else {
      await _personRepository.addPerson(newPerson);
    }

    // Refresh Home
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchPeople();
    }

    Get.back();
  }

  void addAnniversary(String title, DateTime date) {
    anniversaries.add(
      Anniversary(
        id: const Uuid().v4(),
        personId: personId ?? '', // Will be updated on save if new
        title: title,
        date: date,
        type: AnniversaryType.etc, // Default
      ),
    );
  }

  void addMemo(String content) {
    memos.add(
      Memo(
        id: const Uuid().v4(),
        personId: personId ?? '',
        createdAt: DateTime.now(),
        content: content,
      ),
    );
    newMemoController.clear();
  }

  void addPreference(String title, String? like, String? dislike) {
    preferences.add(
      PreferenceCategory(
        id: const Uuid().v4(),
        personId: personId ?? '',
        title: title,
        like: like,
        dislike: dislike,
      ),
    );
  }

  void updateAnniversary(int index, String title, DateTime date) {
    final oldAnniv = anniversaries[index];
    anniversaries[index] = Anniversary(
      id: oldAnniv.id,
      personId: oldAnniv.personId,
      title: title,
      date: date,
      type: oldAnniv.type,
    );
  }

  void removeAnniversary(int index) {
    anniversaries.removeAt(index);
  }

  void updatePreference(
    int index,
    String title,
    String? like,
    String? dislike,
  ) {
    final oldPref = preferences[index];
    preferences[index] = PreferenceCategory(
      id: oldPref.id,
      personId: oldPref.personId,
      title: title,
      like: like,
      dislike: dislike,
    );
  }

  void updateMemo(int index, String content) {
    final oldMemo = memos[index];
    memos[index] = Memo(
      id: oldMemo.id,
      personId: oldMemo.personId,
      createdAt: oldMemo.createdAt,
      content: content,
    );
  }

  void removeMemo(int index) {
    memos.removeAt(index);
  }

  void removePreference(int index) {
    preferences.removeAt(index);
  }
}
