// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 0;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDate: fields[3] as DateTime?,
      phone: fields[4] as String?,
      address: fields[5] as String?,
      email: fields[6] as String?,
      groupId: fields[7] as String,
      anniversaries: (fields[8] as List).cast<Anniversary>(),
      memos: (fields[9] as List).cast<Memo>(),
      preferences: (fields[10] as List).cast<PreferenceCategory>(),
      mbti: fields[11] as String?,
      extraInfo:
          fields[12] == null ? {} : (fields[12] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.groupId)
      ..writeByte(8)
      ..write(obj.anniversaries)
      ..writeByte(9)
      ..write(obj.memos)
      ..writeByte(10)
      ..write(obj.preferences)
      ..writeByte(11)
      ..write(obj.mbti)
      ..writeByte(12)
      ..write(obj.extraInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
