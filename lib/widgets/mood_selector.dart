import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../constants/moods.dart';
import '../repositories/mood_repository.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;
  final _moodRepository = MoodRepository();
  MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allMoods.map((mood) {
              final isSelected = selectedMood == mood['label'];
              final isCustom = mood['isCustom'] == true;
              final moodColor =
                  mood['color'] as Color? ?? AppColors.textSecondary;

              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onMoodSelected(mood['label']);
                  },
                  child: Column(
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
                ),
              );
            }).toList(),
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
