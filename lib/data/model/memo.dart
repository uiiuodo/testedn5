import 'package:hive/hive.dart';

part 'memo.g.dart';

@HiveType(typeId: 4)
class Memo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String content;

  Memo({
    required this.id,
    required this.personId,
    required this.createdAt,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] ?? '',
      personId: map['personId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      content: map['content'] ?? '',
    );
  }
}
