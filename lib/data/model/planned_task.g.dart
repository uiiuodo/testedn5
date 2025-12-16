// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannedTaskAdapter extends TypeAdapter<PlannedTask> {
  @override
  final int typeId = 8;

  @override
  PlannedTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedTask(
      id: fields[0] as String,
      content: fields[1] as String,
      createdAt: fields[2] as DateTime,
      groupId: fields[3] as String?,
      personId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.groupId)
      ..writeByte(4)
      ..write(obj.personId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
