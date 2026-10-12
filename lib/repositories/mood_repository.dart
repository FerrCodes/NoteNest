import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/custom_mood.dart';
import '../constants/moods.dart';

class MoodRepository {
  static const int maxCustomMoods = 10;

  final Box<CustomMood> _box = Hive.box<CustomMood>('customMoodsBox');

  /// Ambil semua mood custom, urutkan dari yang terbaru.
  List<CustomMood> getAllCustomMoods() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Ambil semua label mood custom saja.
  List<String> getCustomMoodLabels() {
    return getAllCustomMoods().map((m) => m.label).toList();
  }

  /// Jumlah mood custom saat ini.
  int get customMoodCount => _box.length;

  /// Apakah sudah mencapai batas maksimal?
  bool get isAtMaxCapacity => _box.length >= maxCustomMoods;

  /// Cek apakah label sudah dipakai (baik preset maupun custom).
  bool isLabelTaken(String label) {
    final normalized = label.trim().toLowerCase();
    // Cek preset
    if (MoodPresets.labels.map((l) => l.toLowerCase()).contains(normalized)) {
      return true;
    }
    // Cek custom
    return getAllCustomMoods().any((m) => m.label.toLowerCase() == normalized);
  }

  /// Tambah mood custom baru.
  /// Return true kalau berhasil, false kalau gagal (label duplikat / penuh).
  Future<bool> addCustomMood(
    String label, {
    String iconName = 'mood',
    String colorHex = '0xFF8E8E93',
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return false;
    if (isLabelTaken(trimmed)) return false;
    if (isAtMaxCapacity) return false;

    final mood = CustomMood(
      label: trimmed,
      iconName: iconName,
      createdAt: DateTime.now(),
      colorHex: colorHex,
    );
    await _box.add(mood);
    return true;
  }

  /// Hapus mood custom berdasarkan objek.
  Future<void> deleteCustomMood(CustomMood mood) async {
    await mood.delete();
  }

  /// Ambil listenable box, untuk ValueListenableBuilder di UI.
  ValueListenable<Box<CustomMood>> get listenable => _box.listenable();
}
