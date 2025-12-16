import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 1)
class Group {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  Group({required this.id, required this.name, required this.colorValue});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'colorValue': colorValue};
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFFEEEEEE,
    );
  }
}
