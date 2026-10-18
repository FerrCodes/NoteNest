import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HapticService {
  /// Cek apakah getaran diaktifkan di Settings (default: true)
  static bool get _isEnabled {
    try {
      final box = Hive.box('settingsBox');
      return box.get('hapticEnabled', defaultValue: true);
    } catch (e) {
      // Fallback kalau box belum siap
      return true;
    }
  }

  /// Untuk tap tombol, navigasi, pilih chip.
  static void selectionClick() {
    if (_isEnabled) HapticFeedback.selectionClick();
  }

  /// Untuk aksi ringan (buka modal, dll).
  static void lightImpact() {
    if (_isEnabled) HapticFeedback.lightImpact();
  }

  /// Untuk aksi penting (simpan jurnal, nyalakan fitur).
  static void mediumImpact() {
    if (_isEnabled) HapticFeedback.mediumImpact();
  }

  /// Untuk aksi berbahaya (hapus, reset).
  static void heavyImpact() {
    if (_isEnabled) HapticFeedback.heavyImpact();
  }
}
