// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferenceCategoryAdapter extends TypeAdapter<PreferenceCategory> {
  @override
  final int typeId = 5;

  @override
  PreferenceCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PreferenceCategory(
      id: fields[0] as String,
      personId: fields[1] as String,
      title: fields[2] as String,
      like: fields[3] as String?,
      dislike: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PreferenceCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.like)
      ..writeByte(4)
      ..write(obj.dislike);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
