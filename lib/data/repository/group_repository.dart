import 'package:hive/hive.dart';
import '../model/group.dart';

class GroupRepository {
  final Box<Group> _box = Hive.box<Group>('groups');

  List<Group> getGroups() {
    return _box.values.toList();
  }

  Future<void> addGroup(Group group) async {
    await _box.put(group.id, group);
  }

  Group? getGroup(String id) {
    try {
      return _box.values.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}
