// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_mood.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomMoodAdapter extends TypeAdapter<CustomMood> {
  @override
  final int typeId = 1;

  @override
  CustomMood read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomMood(
      label: fields[0] as String,
      iconName: fields[1] as String,
      createdAt: fields[2] as DateTime,
      colorHex: fields[3] as String,
      isArchived: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomMood obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.iconName)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
