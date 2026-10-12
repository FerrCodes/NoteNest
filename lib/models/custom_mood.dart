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

  @HiveField(3)
  String colorHex;

  /// True kalau mood ini sudah "dihapus" oleh user.
  /// Data tetap ada, tapi tidak muncul di pilihan baru.
  @HiveField(4)
  bool isArchived;

  CustomMood({
    required this.label,
    this.iconName = 'mood',
    required this.createdAt,
    this.colorHex = '0xFF8E8E93',
    this.isArchived = false, // Default: tidak diarsipkan
  });
}
