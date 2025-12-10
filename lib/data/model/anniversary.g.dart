// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anniversary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnniversaryAdapter extends TypeAdapter<Anniversary> {
  @override
  final int typeId = 3;

  @override
  Anniversary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anniversary(
      id: fields[0] as String,
      personId: fields[1] as String,
      title: fields[2] as String,
      date: fields[3] as DateTime,
      type: fields[4] as AnniversaryType,
      hasYear: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Anniversary obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.hasYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnniversaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnniversaryTypeAdapter extends TypeAdapter<AnniversaryType> {
  @override
  final int typeId = 2;

  @override
  AnniversaryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnniversaryType.birthday;
      case 1:
        return AnniversaryType.etc;
      default:
        return AnniversaryType.birthday;
    }
  }

  @override
  void write(BinaryWriter writer, AnniversaryType obj) {
    switch (obj) {
      case AnniversaryType.birthday:
        writer.writeByte(0);
        break;
      case AnniversaryType.etc:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnniversaryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
