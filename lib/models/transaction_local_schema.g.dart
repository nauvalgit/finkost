// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_local_schema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionLocalSchemaAdapter
    extends TypeAdapter<TransactionLocalSchema> {
  @override
  final int typeId = 1;

  @override
  TransactionLocalSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionLocalSchema()
      ..firestoreId = fields[0] as String?
      ..amount = fields[1] as double
      ..description = fields[2] as String?
      ..date = fields[3] as DateTime
      ..transactionType = fields[4] as String
      ..userId = fields[5] as String
      ..categoryName = fields[6] as String
      ..categoryIcon = fields[7] as String
      ..createdAt = fields[8] as DateTime
      ..updatedAt = fields[9] as DateTime;
  }

  @override
  void write(BinaryWriter writer, TransactionLocalSchema obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.firestoreId)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.transactionType)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.categoryName)
      ..writeByte(7)
      ..write(obj.categoryIcon)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionLocalSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
