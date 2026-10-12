import 'package:hive/hive.dart';

part 'custom_mood.g.dart';

@HiveType(typeId: 1)
class CustomMood extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  String iconName;

  @HiveField(2)
  DateTime createdAt;

  /// Warna mood dalam format hex string (misal '0xFF0A84FF').
  /// Disimpan sebagai string karena Hive tidak support Color langsung.
  @HiveField(3)
  String colorHex;

  CustomMood({
    required this.label,
    this.iconName = 'mood',
    required this.createdAt,
    this.colorHex = '0xFF8E8E93', // Default: System Gray
  });
}
