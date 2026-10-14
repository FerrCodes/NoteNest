import 'package:flutter/material.dart';

class MoodPresets {
  static const List<Map<String, dynamic>> all = [
    {
      'icon': Icons.wb_sunny_outlined,
      'label': 'Calm',
      'color': Color(0xFFFFD60A),
    },
    {
      'icon': Icons.favorite_border,
      'label': 'Grateful',
      'color': Color(0xFFFF375F),
    },
    {
      'icon': Icons.cloud_outlined,
      'label': 'Peaceful',
      'color': Color(0xFF0A84FF),
    },
    {
      'icon': Icons.eco_outlined,
      'label': 'Focused',
      'color': Color(0xFF30D158),
    },
    {
      'icon': Icons.auto_awesome,
      'label': 'Excited',
      'color': Color(0xFFFF9F0A),
    },
  ];

  static List<String> get labels =>
      all.map((m) => m['label'] as String).toList();

  static bool isPreset(String label) => labels.contains(label);

  static IconData? getIcon(String label) {
    final mood = all.firstWhere((m) => m['label'] == label, orElse: () => {});
    return mood['icon'] as IconData?;
  }

  /// Ambil warna untuk mood preset. Return null kalau bukan preset.
  static Color? getColor(String label) {
    final mood = all.firstWhere((m) => m['label'] == label, orElse: () => {});
    return mood['color'] as Color?;
  }
}
