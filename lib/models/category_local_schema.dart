import 'package:hive/hive.dart';

part 'category_local_schema.g.dart';

@HiveType(typeId: 0)
class CategoryLocalSchema extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  String? icon;

  @HiveField(2)
  late String type; 

  @HiveField(3)
  String? firestoreId;

  @HiveField(4)
  late String userId;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;

  CategoryLocalSchema() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  CategoryLocalSchema.create({
    required this.name,
    required this.type,
    this.icon,
    this.firestoreId,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'type': type,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CategoryLocalSchema copyWith({
    String? firestoreId,
    String? name,
    String? icon,
    String? type,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryLocalSchema.create(
      firestoreId: firestoreId ?? this.firestoreId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}