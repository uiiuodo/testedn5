import 'package:get/get.dart';
import '../../../data/model/person.dart';
import '../../../data/model/group.dart';
import '../../../data/repository/person_repository.dart';
import '../../../data/repository/group_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final PersonRepository _personRepository = PersonRepository();
  final GroupRepository _groupRepository = GroupRepository();

  final RxList<Person> people = <Person>[].obs;
  final RxList<Group> groups = <Group>[].obs;
  final RxString selectedGroupId = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxInt tabIndex = 0.obs;
  final RxBool isReorderMode = false.obs;

  List<Person> get filteredPeople {
    // Return people in their current order (which is sorted by _sortPeople)
    return people.where((person) {
      final matchesGroup =
          selectedGroupId.value == 'all' ||
          person.groupId == selectedGroupId.value;
      final matchesSearch = person.name.contains(searchQuery.value);
      return matchesGroup && matchesSearch;
    }).toList();
  }

  List<Group> get usedGroups {
    final usedIds = people.map((p) => p.groupId).toSet();
    return groups.where((g) => usedIds.contains(g.id)).toList();
  }

  void selectGroup(String groupId) {
    selectedGroupId.value = groupId;
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void addGroup(String name, int colorValue) async {
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Simple ID generation
      name: name,
      colorValue: colorValue,
    );
    await _groupRepository.addGroup(newGroup);
    fetchGroups();
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
      selectedGroupId.value = 'all';
    }
  }

  Future<void> deletePerson(String id) async {
    await _personRepository.deletePerson(id);
    fetchPeople();
  }

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    fetchPeople();
    _loadPersonOrder();
  }

  Future<void> fetchGroups() async {
    final loadedGroups = _groupRepository.getGroups();
    loadedGroups.sort((a, b) => a.name.compareTo(b.name));
    groups.value = loadedGroups;
  }

  Future<void> fetchPeople() async {
    people.value = await _personRepository.getPeople();
    _sortPeople();
  }

  // Reordering Logic
  final RxList<String> _personOrder = <String>[].obs;

  void _loadPersonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    _personOrder.value = prefs.getStringList('person_order') ?? [];
    // Re-sort people if they are already loaded
    if (people.isNotEmpty) {
      _sortPeople();
      people.refresh();
    }
  }

  void _savePersonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('person_order', _personOrder);
  }

  void _sortPeople() {
    if (_personOrder.isEmpty) {
      people.sort((a, b) => a.name.compareTo(b.name));
      return;
    }

    final orderMap = {
      for (var i = 0; i < _personOrder.length; i++) _personOrder[i]: i,
    };

    people.sort((a, b) {
      final indexA = orderMap[a.id] ?? 999999;
      final indexB = orderMap[b.id] ?? 999999;
      // If both are new (999999), sort them alphabetically
      if (indexA == 999999 && indexB == 999999) {
        return a.name.compareTo(b.name);
      }
      return indexA.compareTo(indexB);
    });
  }

  void reorderPeople(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // We need to reorder the *filtered* list if we are viewing a subset,
    // but typically reordering makes most sense in the "All" view or we need to handle it carefully.
    // For this requirement, we'll assume reordering affects the global order.
    // However, the UI passes indices from the `filteredPeople` list.
    // If we are filtered, reordering might be ambiguous.
    // Let's assume reordering is primarily for the "All" view or we map back to the global list.
    // For simplicity and robustness, let's operate on the displayed list IDs and update the global order.

    // If this is the first reorder, initialize the order list with current alphabetical order
    if (_personOrder.isEmpty) {
      _personOrder.addAll(people.map((p) => p.id));
    }

    final currentList = filteredPeople;
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);

    // Now update the global _personOrder based on this new arrangement
    // We'll reconstruct _personOrder:
    // 1. Start with existing _personOrder
    // 2. Remove the moved item's ID
    // 3. Insert it at the new relative position... this is tricky if filtered.

    // Simpler approach: Just update the global order based on the visual change if we are in "All" view.
    // If we are in a filtered view, reordering might just change the relative order of those items.

    // Let's go with: Update _personOrder to reflect the new sequence of IDs.
    // If the list is filtered, we only swap the relative positions of the visible items in the global order.

    // Actually, the user requirement implies reordering the list they see.
    // Let's just update the global order list.

    // 1. Remove the ID from the order list
    _personOrder.remove(item.id);

    // 2. Find the ID of the item that is now *after* the moved item in the visual list
    String? nextItemId;
    if (newIndex + 1 < currentList.length) {
      nextItemId = currentList[newIndex + 1].id;
    }

    // 3. Insert before that item in the global list
    if (nextItemId != null) {
      final nextItemGlobalIndex = _personOrder.indexOf(nextItemId);
      if (nextItemGlobalIndex != -1) {
        _personOrder.insert(nextItemGlobalIndex, item.id);
      } else {
        _personOrder.add(item.id); // Fallback
      }
    } else {
      // Moved to end of visual list
      // Find the ID of the item *before* it in the visual list
      if (newIndex > 0) {
        final prevItemId = currentList[newIndex - 1].id;
        final prevItemGlobalIndex = _personOrder.indexOf(prevItemId);
        if (prevItemGlobalIndex != -1) {
          _personOrder.insert(prevItemGlobalIndex + 1, item.id);
        } else {
          _personOrder.add(item.id);
        }
      } else {
        _personOrder.insert(0, item.id); // Start of list
      }
    }

    _savePersonOrder();
    _sortPeople();
    people.refresh();
  }
}
