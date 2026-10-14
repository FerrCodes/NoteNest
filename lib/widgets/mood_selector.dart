import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../constants/moods.dart';
import '../repositories/mood_repository.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;
  final String? currentMood;
  final _moodRepository = MoodRepository();
  MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.currentMood,
  });

  String _getLocalizedMood(BuildContext context, String mood) {
    final l10n = AppLocalizations.of(context)!;
    switch (mood) {
      case 'Calm':
        return l10n.filterCalm;
      case 'Grateful':
        return l10n.filterGrateful;
      case 'Peaceful':
        return l10n.filterPeaceful;
      case 'Focused':
        return l10n.filterFocused;
      case 'Excited':
        return l10n.filterExcited;
      default:
        return mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _moodRepository.listenable,
      builder: (context, box, _) {
        final presetMoods = MoodPresets.all;
        final customMoods = _moodRepository.getAllCustomMoods();
        final allMoods = <Map<String, dynamic>>[
          ...presetMoods,
          ...customMoods.map(
            (m) => {
              'icon': Icons.mood_outlined,
              'label': m.label,
              'color': _hexToColor(m.colorHex),
              'isCustom': true,
            },
          ),
        ];

        // Kalau currentMood tidak ada di allMoods (misal: mood arsip),
        // tambahkan sebagai legacy mood
        final currentMoodExists = allMoods.any(
          (m) => m['label'] == currentMood,
        );

        if (currentMood != null &&
            currentMood!.isNotEmpty &&
            !currentMoodExists) {
          allMoods.insert(0, {
            'icon': Icons.mood_outlined,
            'label': currentMood,
            'color': AppColors.textSecondary,
            'isCustom': true,
            'isLegacy': true,
          });
        }

        return SizedBox(
          height: 90, // Tinggi tetap untuk ListView
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16), // kiri & kanan
            itemCount: allMoods.length,
            separatorBuilder: (_, _) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final mood = allMoods[index];
              final isSelected = selectedMood == mood['label'];
              final isCustom = mood['isCustom'] == true;
              final moodColor =
                  mood['color'] as Color? ?? AppColors.textSecondary;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onMoodSelected(mood['label']);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? moodColor : AppColors.cardDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? moodColor
                              : moodColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        mood['icon'],
                        color: isSelected ? Colors.white : moodColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCustom
                          ? mood['label']
                          : _getLocalizedMood(context, mood['label']),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Helper: Convert hex string ke Color
Color _hexToColor(String hex) {
  final cleaned = hex.replaceAll('0x', '').replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
