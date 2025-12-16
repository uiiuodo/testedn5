import 'package:hive/hive.dart';

part 'anniversary.g.dart';

@HiveType(typeId: 2)
enum AnniversaryType {
  @HiveField(0)
  birthday,
  @HiveField(1)
  etc,
}

@HiveType(typeId: 3)
class Anniversary {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final AnniversaryType type;

  @HiveField(5)
  final bool hasYear;

  Anniversary({
    required this.id,
    required this.personId,
    required this.title,
    required this.date,
    required this.type,
    this.hasYear = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.index, // Hive uses index, Firestore can too or string
      'hasYear': hasYear,
    };
  }

  factory Anniversary.fromMap(Map<String, dynamic> map) {
    return Anniversary(
      id: map['id'] ?? '',
      personId: map['personId'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      type: AnniversaryType.values[map['type'] as int],
      hasYear: map['hasYear'] ?? true,
    );
  }
}
