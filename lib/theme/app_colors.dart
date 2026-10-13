import 'package:flutter/material.dart';

/// Kumpulan warna yang dipakai di seluruh aplikasi.
///
/// Mengikuti palet warna iOS (Apple Human Interface Guidelines).
/// Semua warna di sini adalah "Source of Truth" — kalau mau ganti warna,
/// cukup ubah di sini saja.
class AppColors {
  // === BACKGROUND & SURFACE ===
  /// Background utama aplikasi (dark mode).
  static const Color bgDark = Color(0xFF121212);

  /// Warna kartu/surface (dark mode).
  static const Color cardDark = Color(0xFF1E1E1E);

  /// Warna divider atau garis tipis.
  static const Color dividerDark = Color.fromARGB(255, 66, 66, 68);

  // === TEXT ===
  /// Warna teks utama (putih terang).
  static const Color textPrimary = Color(0xFFF2F2F7);

  /// Warna teks sekunder (abu-abu).
  static const Color textSecondary = Color(0xFF8E8E93);

  // === SYSTEM COLORS (iOS Palette) ===
  /// System Blue — warna aksen utama iOS (tombol, link).
  static const Color systemBlue = Color(0xFF0A84FF);

  /// System Yellow — untuk streak, favorite bookmark.
  static const Color systemYellow = Color(0xFFFFD60A);

  /// System Red — untuk delete, danger zone.
  static const Color systemRed = Color(0xFFFF453A);

  /// System Green — untuk success state.
  static const Color systemGreen = Color(0xFF30D158);

  /// System Gray — versi lebih gelap untuk secondary background.
  static const Color systemGray = Color(0xFF8E8E93);
}
