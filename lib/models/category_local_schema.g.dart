// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_local_schema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryLocalSchemaAdapter extends TypeAdapter<CategoryLocalSchema> {
  @override
  final int typeId = 0;

  @override
  CategoryLocalSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryLocalSchema()
      ..name = fields[0] as String
      ..icon = fields[1] as String?
      ..type = fields[2] as String
      ..firestoreId = fields[3] as String?
      ..userId = fields[4] as String
      ..createdAt = fields[5] as DateTime
      ..updatedAt = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CategoryLocalSchema obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.firestoreId)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLocalSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
