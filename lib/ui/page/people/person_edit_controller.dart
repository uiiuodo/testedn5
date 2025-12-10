import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:lunar/lunar.dart';
import '../../../data/model/person.dart';
import '../../../data/model/group.dart';
import '../../../data/model/anniversary.dart';
import '../../../data/model/memo.dart';
import '../../../data/model/preference_category.dart';
import '../../../data/repository/person_repository.dart';
import '../../../data/repository/group_repository.dart';
import '../../../service/person_metadata_service.dart';
import '../../../service/birthday_scheduler.dart';
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
  final RxBool isLunarBirth = false.obs;
  final Rx<DateTime?> lunarBirthDate = Rx<DateTime?>(null);
  final RxBool isLeapMonth =
      false.obs; // For Lunar leap month support if needed
  final RxString selectedGroupId = ''.obs;

  // Visibility Flags
  final RxBool showBirthDate = true.obs;
  final RxBool showPhone = true.obs;
  final RxBool showAddress = true.obs;
  final RxBool showEmail = true.obs;
  final RxBool showMbti = true.obs;

  final RxList<Anniversary> anniversaries = <Anniversary>[].obs;
  final RxList<Memo> memos = <Memo>[].obs;
  final RxList<PreferenceCategory> preferences = <PreferenceCategory>[].obs;

  // New Fields (Memory Only)
  final mbtiController = TextEditingController();
  final RxBool showLunar = false.obs; // Legacy, check if used
  final RxList<MapEntry<String, TextEditingController>> customFields =
      <MapEntry<String, TextEditingController>>[].obs;
  final RxString koreanAge = ''.obs;

  final RxList<Group> groups = <Group>[].obs;

  // UI State for inline adding
  final RxBool isAddingAnniversary = false.obs;
  final Rx<DateTime> newAnniversaryDate = Rx<DateTime>(DateTime.now());
  final RxBool newAnniversaryHasYear = true.obs;
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

    // Listen to birthDate changes to calculate Korean Age
    ever(birthDate, (_) => _calculateKoreanAge());
  }

  void _calculateKoreanAge() {
    if (birthDate.value == null) {
      koreanAge.value = '';
      return;
    }
    final now = DateTime.now();
    final birthYear = birthDate.value!.year;
    final currentYear = now.year;
    // Korean Age (Man Age) calculation
    int age = currentYear - birthYear;
    if (now.month < birthDate.value!.month ||
        (now.month == birthDate.value!.month &&
            now.day < birthDate.value!.day)) {
      age--;
    }
    koreanAge.value = '만 $age세';
  }

  void setBirthDate(DateTime date, bool isLunar) {
    if (isLunar) {
      final lunar = Lunar.fromYmd(date.year, date.month, date.day);
      final solar = lunar.getSolar();
      final solarDate = DateTime(
        solar.getYear(),
        solar.getMonth(),
        solar.getDay(),
      );

      lunarBirthDate.value = date;
      birthDate.value = solarDate;
      isLunarBirth.value = true;
    } else {
      lunarBirthDate.value = null;
      birthDate.value = date;
      isLunarBirth.value = false;
    }
  }

  void pickBirthDate(BuildContext context) async {
    // We will use a custom dialog in the UI to handle Solar/Lunar selection
    // This method might be deprecated or updated to show that dialog
  }

  void fetchGroups() {
    final loadedGroups = _groupRepository.getGroups();
    loadedGroups.sort((a, b) => a.name.compareTo(b.name));
    groups.value = loadedGroups;
  }

  void addNewGroup(String name, int colorValue) async {
    final newGroup = Group(
      id: const Uuid().v4(),
      name: name,
      colorValue: colorValue,
    );

    await _groupRepository.addGroup(newGroup);
    fetchGroups();
    selectedGroupId.value = newGroup.id;
  }

  void updateGroup(String id, String newName) async {
    final group = groups.firstWhereOrNull((g) => g.id == id);
    if (group != null) {
      final updatedGroup = Group(
        id: group.id,
        name: newName,
        colorValue: group.colorValue,
      );
      await _groupRepository.updateGroup(updatedGroup);
      fetchGroups();
    }
  }

  void deleteGroup(String id) async {
    await _groupRepository.deleteGroup(id);
    fetchGroups();
    if (selectedGroupId.value == id) {
      selectedGroupId.value = '';
    }
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

      // Note: MBTI, Custom Fields, Lunar info are not loaded as they are not in the model yet.

      // We do NOT set visibility flags to false here, because we want them visible by default
      // so the user can edit them. They are UI state only.
      // If we wanted to hide empty fields, we would do:
      // showPhone.value = person.phone != null && person.phone!.isNotEmpty;
      // But per instructions, we initialize them to true.
      // Load Lunar Metadata
      final metadataService = Get.find<PersonMetadataService>();
      isLunarBirth.value = metadataService.getIsLunar(id);
      lunarBirthDate.value = metadataService.getLunarDate(id);
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
      // Note: MBTI, Custom Fields, Lunar info are not saved as they are not in the model yet.
    );

    if (personId != null) {
      await _personRepository.updatePerson(newPerson);
    } else {
      await _personRepository.addPerson(newPerson);
    }

    // Save Lunar Metadata
    final metadataService = Get.find<PersonMetadataService>();
    await metadataService.setLunarBirthday(
      newPerson.id,
      isLunarBirth.value,
      lunarBirthDate.value,
    );

    // Schedule Birthday Event
    await BirthdayScheduler.scheduleBirthday(newPerson);
    // Schedule Anniversary Events
    await BirthdayScheduler.scheduleAnniversaries(newPerson);

    // Refresh Home
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchPeople();
    }

    Get.back();
  }

  // Anniversary Logic
  void addAnniversary(String title, DateTime date, bool hasYear) {
    anniversaries.add(
      Anniversary(
        id: const Uuid().v4(),
        personId: personId ?? '',
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
        personId: personId ?? '',
        title: '',
        date: DateTime.now(),
        type: AnniversaryType.etc,
        hasYear: true,
      ),
    );
  }

  void removeAnniversary(int index) {
    anniversaries.removeAt(index);
  }

  void updateAnniversary(int index, String title, DateTime date, bool hasYear) {
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

  // Memo Logic
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

  void addEmptyMemo() {
    memos.add(
      Memo(
        id: const Uuid().v4(),
        personId: personId ?? '',
        createdAt: DateTime.now(),
        content: '',
      ),
    );
  }

  void removeMemo(int index) {
    memos.removeAt(index);
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

  // Preference Logic
  void addPreference(String title, String like, String dislike) {
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

  void updatePreference(int index, String title, String like, String dislike) {
    final oldPref = preferences[index];
    preferences[index] = PreferenceCategory(
      id: oldPref.id,
      personId: oldPref.personId,
      title: title,
      like: like,
      dislike: dislike,
    );
  }

  void removePreference(int index) {
    preferences.removeAt(index);
  }

  void addCustomField(String title, String content) {
    customFields.add(MapEntry(title, TextEditingController(text: content)));
  }

  void removeCustomField(int index) {
    customFields.removeAt(index);
  }
}
