import 'package:hive/hive.dart';
import 'anniversary.dart';
import 'memo.dart';
import 'preference_category.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 8)
class UserProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime? birthDate;

  @HiveField(3)
  final List<Anniversary> anniversaries;

  @HiveField(4)
  final List<Memo> memos;

  @HiveField(5)
  final List<PreferenceCategory> preferences;

  UserProfile({
    required this.id,
    required this.name,
    this.birthDate,
    this.anniversaries = const [],
    this.memos = const [],
    this.preferences = const [],
  });
}
