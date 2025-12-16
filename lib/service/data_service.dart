import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/model/person.dart';
import '../data/model/group.dart';
import '../data/model/anniversary.dart';
import '../data/model/memo.dart';
import '../data/model/preference_category.dart';
import '../data/model/schedule.dart';
import '../data/model/planned_task.dart';

class DataService extends GetxService {
  Future<DataService> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(AnniversaryAdapter());
    Hive.registerAdapter(AnniversaryTypeAdapter());
    Hive.registerAdapter(MemoAdapter());
    Hive.registerAdapter(PreferenceCategoryAdapter());
    Hive.registerAdapter(ScheduleAdapter());
    Hive.registerAdapter(ScheduleTypeAdapter());
    Hive.registerAdapter(PlannedTaskAdapter());

    // Open Boxes
    await Hive.openBox<Person>('people');
    await Hive.openBox<Schedule>('schedules');
    await Hive.openBox<PlannedTask>('planned_tasks');

    return this;
  }
}
