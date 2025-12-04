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
}
