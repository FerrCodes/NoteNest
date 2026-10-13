import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String date;

  // Field lama — tetap dipertahankan untuk kompatibilitas data lama.
  // Jangan dipakai di kode baru.
  @HiveField(3)
  String imageUrl;

  @HiveField(4)
  String mood;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  DateTime? lastEdited;

  // Field baru: daftar foto (max 4).
  @HiveField(7)
  List<String> imageUrls;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl = '', // default kosong
    this.mood = 'Calm',
    this.isFavorite = false,
    this.lastEdited,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];

  /// Foto utama — untuk ditampilkan di kartu beranda.
  /// Kalau `imageUrls` kosong, fallback ke `imageUrl` lama.
  /// Kalau keduanya kosong, return default preset.
  String get primaryImageUrl {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    if (imageUrl.isNotEmpty) return imageUrl;
    return 'assets/presets/photo-1.jpg'; // fallback
  }

  /// Cek apakah jurnal punya lebih dari 1 foto.
  bool get hasMultiplePhotos => imageUrls.length > 1;
}
