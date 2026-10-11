import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  static final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.wb_sunny_outlined, 'label': 'Calm'},
    {'icon': Icons.favorite_border, 'label': 'Grateful'},
    {'icon': Icons.cloud_outlined, 'label': 'Peaceful'},
    {'icon': Icons.eco_outlined, 'label': 'Focused'},
  ];

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood['label'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onMoodSelected(mood['label']);
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? textPrimary : cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mood['icon'],
                  color: isSelected ? bgColor : textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getLocalizedMood(context, mood['label']),
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? textPrimary : textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
