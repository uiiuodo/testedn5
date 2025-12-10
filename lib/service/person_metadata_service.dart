import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonMetadataService extends GetxService {
  late SharedPreferences _prefs;

  Future<PersonMetadataService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Keys
  String _getIsLunarKey(String personId) => 'person_${personId}_is_lunar';
  String _getLunarDateKey(String personId) => 'person_${personId}_lunar_date';

  // Setters
  Future<void> setLunarBirthday(
    String personId,
    bool isLunar,
    DateTime? lunarDate,
  ) async {
    await _prefs.setBool(_getIsLunarKey(personId), isLunar);
    if (lunarDate != null) {
      await _prefs.setString(
        _getLunarDateKey(personId),
        lunarDate.toIso8601String(),
      );
    } else {
      await _prefs.remove(_getLunarDateKey(personId));
    }
  }

  // Getters
  bool getIsLunar(String personId) {
    return _prefs.getBool(_getIsLunarKey(personId)) ?? false;
  }

  DateTime? getLunarDate(String personId) {
    final dateStr = _prefs.getString(_getLunarDateKey(personId));
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
}
