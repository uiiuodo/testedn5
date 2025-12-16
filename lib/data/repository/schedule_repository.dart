import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../service/auth_service.dart';
import '../model/schedule.dart';

class ScheduleRepository {
  // Hive Legacy
  // final Box<Schedule> _box = Hive.box<Schedule>('schedules');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService get _auth => Get.find<AuthService>();

  String? get _uid => _auth.user.value?.uid;

  Future<List<Schedule>> getSchedules() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('events')
          .get();
      return snapshot.docs.map((doc) => Schedule.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching schedules: $e');
      return [];
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('events')
        .doc(schedule.id)
        .set(schedule.toMap());
  }

  Future<void> updateSchedule(Schedule schedule) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('events')
        .doc(schedule.id)
        .update(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('events')
        .doc(id)
        .delete();
  }

  Future<List<Schedule>> getSchedulesByPerson(String personId) async {
    if (_uid == null) return [];

    // Firestore doesn't support array-contains-any easily without composite index if mixed with other filters.
    // However, personIds is a list. We want schedules where personIds contains personId.
    // .where('personIds', arrayContains: personId)

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('events')
          .where('personIds', arrayContains: personId)
          .get();
      return snapshot.docs.map((doc) => Schedule.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching schedules by person: $e');
      return [];
    }
  }
}
