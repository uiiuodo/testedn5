import 'package:hive/hive.dart';

part 'preference_category.g.dart';

@HiveType(typeId: 5)
class PreferenceCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? like;

  @HiveField(4)
  final String? dislike;

  PreferenceCategory({
    required this.id,
    required this.personId,
    required this.title,
    this.like,
    this.dislike,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'title': title,
      'like': like,
      'dislike': dislike,
    };
  }

  factory PreferenceCategory.fromMap(Map<String, dynamic> map) {
    return PreferenceCategory(
      id: map['id'] ?? '',
      personId: map['personId'] ?? '',
      title: map['title'] ?? '',
      like: map['like'],
      dislike: map['dislike'],
    );
  }
}
