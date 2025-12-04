import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/model/person.dart';
import '../data/model/group.dart';
import '../data/model/anniversary.dart';
import '../data/model/memo.dart';
import '../data/model/preference_category.dart';
import '../data/model/schedule.dart';

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

    // Open Boxes
    await Hive.openBox<Person>('people');
    await Hive.openBox<Group>('groups');
    await Hive.openBox<Schedule>('schedules');

    // Initialize default groups if empty
    final groupBox = Hive.box<Group>('groups');
    if (groupBox.isEmpty) {
      await groupBox.add(
        Group(id: 'family', name: '가족', colorValue: 0xFFFFD1DC),
      );
      await groupBox.add(
        Group(id: 'friend', name: '지인', colorValue: 0xFFFFF5BA),
      );
      await groupBox.add(Group(id: 'work', name: '직장', colorValue: 0xFFD4F0F0));
      await groupBox.add(Group(id: 'etc', name: '기타', colorValue: 0xFFE0E0E0));
    }

    return this;
  }
}
