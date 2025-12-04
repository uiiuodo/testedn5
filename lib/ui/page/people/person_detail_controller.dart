import 'package:get/get.dart';
import '../../../data/model/person.dart';
import '../../../data/repository/person_repository.dart';

class PersonDetailController extends GetxController {
  final PersonRepository _personRepository = PersonRepository();
  final String personId;

  final Rx<Person?> person = Rx<Person?>(null);

  PersonDetailController(this.personId);

  @override
  void onInit() {
    super.onInit();
    loadPerson();
  }

  void loadPerson() {
    person.value = _personRepository.getPerson(personId);
  }
}
