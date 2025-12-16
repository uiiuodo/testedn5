import 'package:hive/hive.dart';
import '../model/planned_task.dart';

class PlannedTaskRepository {
  static const String boxName = 'planned_tasks';

  Box<PlannedTask> get _box => Hive.box<PlannedTask>(boxName);

  List<PlannedTask> getTasks() {
    return _box.values.toList();
  }

  List<PlannedTask> getTasksByGroup(String groupId) {
    if (groupId == 'all') {
      // Return unassigned tasks or all? logic check:
      // "Group Calendar Global" -> 'all' usually means showing everything or just global?
      // Based on previous GroupCalendarController:
      // if (selectedGroupId.value == 'all') { return schedules; }
      // So 'all' returns everything.
      return _box.values.toList();
    }
    return _box.values.where((t) => t.groupId == groupId).toList();
  }

  List<PlannedTask> getTasksByPerson(String personId) {
    return _box.values.where((t) => t.personId == personId).toList();
  }

  Future<void> addTask(PlannedTask task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(PlannedTask task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
