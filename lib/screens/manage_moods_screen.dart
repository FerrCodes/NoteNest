import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../repositories/mood_repository.dart';
import '../models/custom_mood.dart';
import '../widgets/section_title.dart';
import '../widgets/top_banner.dart';

class ManageMoodsScreen extends StatefulWidget {
  const ManageMoodsScreen({super.key});

  @override
  State<ManageMoodsScreen> createState() => _ManageMoodsScreenState();
}

class _ManageMoodsScreenState extends State<ManageMoodsScreen> {
  final _repository = MoodRepository();
  final _moodNameController = TextEditingController();

  final ValueNotifier<String> _selectedColorNotifier = ValueNotifier<String>(
    '0xFF0A84FF',
  );

  static const List<String> _colorOptions = [
    '0xFF0A84FF', // Blue
    '0xFF30D158', // Green
    '0xFFFFD60A', // Yellow
    '0xFFFF9F0A', // Orange
    '0xFFFF375F', // Pink
    '0xFFBF5AF2', // Purple
    '0xFF64D2FF', // Cyan
    '0xFF8E8E93', // Gray
  ];

  @override
  void dispose() {
    _moodNameController.dispose();
    _selectedColorNotifier.dispose();
    super.dispose();
  }

  void _showAddMoodSheet() {
    if (_repository.isAtMaxCapacity) {
      _showSnackBar(
        AppLocalizations.of(context)!.moodLimitReached,
        type: BannerType.error,
      );
      return;
    }

    _moodNameController.clear();
    _selectedColorNotifier.value = '0xFF0A84FF';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.newMood,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _moodNameController,
                autofocus: true,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.moodNameHint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.bgDark,
                  counterStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Warna Mood', // Bisa pakai l10n nanti
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // === COLOR PICKER dengan ValueListenableBuilder ===
              ValueListenableBuilder<String>(
                valueListenable: _selectedColorNotifier,
                builder: (context, selectedHex, _) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.map((hex) {
                      final color = _hexToColor(hex);
                      final isSelected = selectedHex == hex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _selectedColorNotifier.value =
                              hex; // <-- Update via notifier
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.textPrimary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: _moodNameController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;
                  return GestureDetector(
                    onTap: hasText ? () => _addMood(value.text) : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: hasText
                            ? AppColors.systemBlue
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.addMood,
                          style: TextStyle(
                            color: hasText
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMood(String label) async {
    final success = await _repository.addCustomMood(
      label,
      colorHex: _selectedColorNotifier.value,
    );

    if (!mounted) return;

    if (!success) {
      HapticFeedback.heavyImpact();
      _showSnackBar(
        AppLocalizations.of(context)!.moodAlreadyExists,
        type: BannerType.error,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    _showSnackBar(AppLocalizations.of(context)!.moodAdded);
  }

  void _confirmDeleteMood(CustomMood mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deleteMoodTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteMoodDesc,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              await _repository.deleteCustomMood(mood);
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSnackBar(AppLocalizations.of(context)!.moodDeleted);
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: AppColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA ===
            ValueListenableBuilder(
              valueListenable: _repository.listenable,
              builder: (context, box, _) {
                final moods = _repository.getAllCustomMoods();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                  children: [
                    // === DESKRIPSI ===
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppLocalizations.of(context)!.manageMoodsDesc,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === SECTION: CUSTOM MOODS ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SectionTitle(
                          title: AppLocalizations.of(context)!.customMoods,
                        ),
                        Text(
                          '${moods.length}/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (moods.isEmpty)
                      _buildEmptyState()
                    else
                      ...moods.map((mood) => _buildMoodItem(mood)),
                  ],
                );
              },
            ),

            // === TOMBOL TAMBAH (KANAN ATAS) ===
            Positioned(
              top: 12,
              right: 20,
              child: _buildCircleButton(
                icon: Icons.add,
                onTap: _showAddMoodSheet,
              ),
            ),

            // === TOMBOL CLOSE (KIRI ATAS) ===
            Positioned(
              top: 12,
              left: 20,
              child: _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // === PILL JUDUL ===
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.manageMoods,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === MOOD ITEM ===
  Widget _buildMoodItem(CustomMood mood) {
    final color = _hexToColor(mood.colorHex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.mood_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                mood.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _confirmDeleteMood(mood);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.systemRed,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === EMPTY STATE ===
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noCustomMoods,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // === TOMBOL BULAT ===
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  // === SNACKBAR HELPER ===
  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('0x', '').replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
