import 'package:hive/hive.dart';
import 'anniversary.dart';
import 'memo.dart';
import 'preference_category.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(3)
  final DateTime? birthDate;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final String? email;

  @HiveField(7)
  final String groupId;

  @HiveField(8)
  final List<Anniversary> anniversaries;

  @HiveField(9)
  final List<Memo> memos;

  @HiveField(10)
  final List<PreferenceCategory> preferences;

  @HiveField(11)
  final String? mbti;

  @HiveField(12, defaultValue: {})
  final Map<String, String> extraInfo;

  Person({
    required this.id,
    required this.name,
    this.birthDate,
    this.phone,
    this.address,
    this.email,
    required this.groupId,
    this.anniversaries = const [],
    this.memos = const [],
    this.preferences = const [],
    this.mbti,
    this.extraInfo = const {},
  });
}
