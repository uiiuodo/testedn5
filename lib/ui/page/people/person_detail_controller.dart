import 'package:get/get.dart';
import '../../../data/model/person.dart';
import '../../../data/repository/person_repository.dart';
import '../../../service/person_metadata_service.dart';

class PersonDetailController extends GetxController {
  final PersonRepository _personRepository = PersonRepository();
  final String personId;

  final Rx<Person?> person = Rx<Person?>(null);
  final RxBool isLunarBirth = false.obs;
  final Rx<DateTime?> lunarBirthDate = Rx<DateTime?>(null);

  PersonDetailController(this.personId);

  @override
  void onInit() {
    super.onInit();
    loadPerson();
  }

  Future<void> loadPerson() async {
    person.value = _personRepository.getPerson(personId);

    // Load Lunar Metadata
    if (Get.isRegistered<PersonMetadataService>()) {
      final metadataService = Get.find<PersonMetadataService>();
      isLunarBirth.value = metadataService.getIsLunar(personId);
      lunarBirthDate.value = metadataService.getLunarDate(personId);
    }
  }
}
