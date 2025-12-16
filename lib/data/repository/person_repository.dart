import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../service/auth_service.dart';
import '../model/person.dart';

class PersonRepository {
  // Hive Legacy
  // final Box<Person> _box = Hive.box<Person>('people');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService get _auth => Get.find<AuthService>();

  String? get _uid => _auth.user.value?.uid;

  Future<List<Person>> getPeople() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('people')
          .get();
      return snapshot.docs.map((doc) => Person.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching people: $e');
      return [];
    }
  }

  Future<Person?> getPerson(String id) async {
    if (_uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('people')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        return Person.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching person: $e');
      return null;
    }
  }

  Future<void> addPerson(Person person) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('people')
        .doc(person.id)
        .set(person.toMap());
  }

  Future<void> updatePerson(Person person) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('people')
        .doc(person.id)
        .update(person.toMap());
  }

  Future<void> deletePerson(String id) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('people')
        .doc(id)
        .delete();
  }
}
