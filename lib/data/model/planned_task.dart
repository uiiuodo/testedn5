import 'package:hive/hive.dart';

part 'planned_task.g.dart';

@HiveType(typeId: 8)
class PlannedTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String? groupId;

  @HiveField(4)
  final String? personId;

  PlannedTask({
    required this.id,
    required this.content,
    required this.createdAt,
    this.groupId,
    this.personId,
  });

  PlannedTask copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? groupId,
    String? personId,
  }) {
    return PlannedTask(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      groupId: groupId ?? this.groupId,
      personId: personId ?? this.personId,
    );
  }
}
