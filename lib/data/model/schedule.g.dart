// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 7;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as String,
      title: fields[1] as String,
      startDateTime: fields[2] as DateTime,
      endDateTime: fields[3] as DateTime,
      allDay: fields[4] as bool,
      type: fields[5] as ScheduleType,
      personIds: (fields[6] as List).cast<String>(),
      groupId: fields[7] as String?,
      isPlanned: fields[8] as bool,
      repeatType: fields[9] as String,
      alarmOffsetMinutes: fields[10] as int?,
      description: fields[11] as String?,
      isAnniversary: fields[12] as bool,
      isImportant: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDateTime)
      ..writeByte(3)
      ..write(obj.endDateTime)
      ..writeByte(4)
      ..write(obj.allDay)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.personIds)
      ..writeByte(7)
      ..write(obj.groupId)
      ..writeByte(8)
      ..write(obj.isPlanned)
      ..writeByte(9)
      ..write(obj.repeatType)
      ..writeByte(10)
      ..write(obj.alarmOffsetMinutes)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.isAnniversary)
      ..writeByte(13)
      ..write(obj.isImportant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleTypeAdapter extends TypeAdapter<ScheduleType> {
  @override
  final int typeId = 6;

  @override
  ScheduleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleType.anniversary;
      case 1:
        return ScheduleType.care;
      case 2:
        return ScheduleType.etc;
      default:
        return ScheduleType.anniversary;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleType obj) {
    switch (obj) {
      case ScheduleType.anniversary:
        writer.writeByte(0);
        break;
      case ScheduleType.care:
        writer.writeByte(1);
        break;
      case ScheduleType.etc:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
