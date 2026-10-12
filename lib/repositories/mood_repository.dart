import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/custom_mood.dart';
import '../constants/moods.dart';

class MoodRepository {
  static const int maxCustomMoods = 10;

  final Box<CustomMood> _box = Hive.box<CustomMood>('customMoodsBox');

  /// Ambil semua mood custom yang TIDAK diarsipkan, urutkan dari yang terbaru.
  List<CustomMood> getAllCustomMoods() {
    return _box.values.where((m) => !m.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Ambil semua mood custom yang diarsipkan.
  List<CustomMood> getArchivedMoods() {
    return _box.values.where((m) => m.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Ambil semua label mood custom saja (yang aktif).
  List<String> getCustomMoodLabels() {
    return getAllCustomMoods().map((m) => m.label).toList();
  }

  /// Jumlah mood custom aktif saat ini.
  int get customMoodCount {
    return _box.values.where((m) => !m.isArchived).length;
  }

  /// Apakah sudah mencapai batas maksimal (hanya hitung yang aktif)?
  bool get isAtMaxCapacity {
    final activeCount = _box.values.where((m) => !m.isArchived).length;
    return activeCount >= maxCustomMoods;
  }

  /// Cek apakah label sudah dipakai (preset, custom aktif, atau custom arsip).
  bool isLabelTaken(String label) {
    final normalized = label.trim().toLowerCase();
    // Cek preset
    if (MoodPresets.labels.map((l) => l.toLowerCase()).contains(normalized)) {
      return true;
    }
    // Cek custom (termasuk yang diarsipkan, supaya user tidak bisa bikin duplikat)
    return _box.values.any((m) => m.label.toLowerCase() == normalized);
  }

  /// Tambah mood custom baru.
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

  /// Arsipkan mood custom (soft delete).
  /// Data tetap ada, tapi tidak muncul di pilihan baru.
  Future<void> archiveCustomMood(CustomMood mood) async {
    mood.isArchived = true;
    await mood.save();
  }

  /// Pulihkan mood custom dari arsip.
  Future<void> restoreCustomMood(CustomMood mood) async {
    mood.isArchived = false;
    await mood.save();
  }

  /// Hapus mood custom secara permanen (hard delete).
  /// Dipakai kalau user mau benar-benar menghapus dari arsip.
  Future<void> deleteCustomMood(CustomMood mood) async {
    await mood.delete();
  }

  /// Ambil listenable box, untuk ValueListenableBuilder di UI.
  ValueListenable<Box<CustomMood>> get listenable => _box.listenable();
}
