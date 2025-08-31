// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_day.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkDayAdapter extends TypeAdapter<WorkDay> {
  @override
  final int typeId = 1;

  @override
  WorkDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkDay(
      weekday: fields[0] as int,
      slots: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.slots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
