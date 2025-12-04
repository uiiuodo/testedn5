import 'package:hive/hive.dart';
import '../model/person.dart';

class PersonRepository {
  final Box<Person> _box = Hive.box<Person>('people');

  List<Person> getPeople() {
    return _box.values.toList();
  }

  Person? getPerson(String id) {
    try {
      return _box.values.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addPerson(Person person) async {
    await _box.put(person.id, person);
  }

  Future<void> updatePerson(Person person) async {
    await _box.put(person.id, person);
  }

  Future<void> deletePerson(String id) async {
    await _box.delete(id);
  }
}
