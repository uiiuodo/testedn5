import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  static String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year + 1; // Korean age
    int manAge = now.year - birthDate.year; // International age
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      manAge--;
    }
    return '($age세, 만 $manAge세)';
  }
}
