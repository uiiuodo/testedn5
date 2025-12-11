import 'package:hive/hive.dart';
import '../model/schedule.dart';

class ScheduleRepository {
  final Box<Schedule> _box = Hive.box<Schedule>('schedules');

  List<Schedule> getSchedules() {
    return _box.values.toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _box.put(schedule.id, schedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _box.put(schedule.id, schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }

  List<Schedule> getSchedulesByPerson(String personId) {
    return _box.values.where((s) => s.personIds.contains(personId)).toList();
  }
}
