import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../repositories/mood_repository.dart';
import '../models/custom_mood.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/top_banner.dart';
import '../services/haptic_service.dart';
import '../widgets/custom_floating_header.dart';

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
  String? _nameError;

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
    _nameError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
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

                          // TextField dengan error inline
                          TextField(
                            controller: _moodNameController,
                            maxLength: 20,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            onChanged: (value) {
                              if (_nameError != null) {
                                setSheetState(() => _nameError = null);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.moodNameHint,
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.bgDark,
                              counterStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null
                                      ? AppColors.systemRed
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null
                                      ? AppColors.systemRed
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null
                                      ? AppColors.systemRed
                                      : AppColors.systemBlue.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              errorText: _nameError,
                              errorStyle: TextStyle(
                                color: AppColors.systemRed,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Section label warna
                          Text(
                            AppLocalizations.of(context)!.moodColor,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Color picker
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
                                      HapticService.selectionClick();
                                      _selectedColorNotifier.value = hex;
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

                          // Tombol Tambah
                          ValueListenableBuilder(
                            valueListenable: _moodNameController,
                            builder: (context, value, child) {
                              final hasText = value.text.trim().isNotEmpty;
                              return GestureDetector(
                                onTap: hasText
                                    ? () => _addMoodWithSheet(
                                        context,
                                        value.text,
                                        setSheetState,
                                      )
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasText
                                        ? AppColors.systemBlue
                                        : AppColors.textSecondary.withValues(
                                            alpha: 0.2,
                                          ),
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addMoodWithSheet(
    BuildContext sheetContext,
    String label,
    StateSetter setSheetState,
  ) async {
    final trimmed = label.trim();

    if (trimmed.isEmpty) {
      setSheetState(() => _nameError = 'Nama mood tidak boleh kosong');
      return;
    }

    if (_repository.isLabelTaken(trimmed)) {
      HapticService.heavyImpact();
      setSheetState(() {
        _nameError = AppLocalizations.of(context)!.moodAlreadyExists;
      });
      return;
    }

    if (_repository.isAtMaxCapacity) {
      HapticService.heavyImpact();
      setSheetState(() {
        _nameError = AppLocalizations.of(context)!.moodLimitReached;
      });
      return;
    }

    final success = await _repository.addCustomMood(
      trimmed,
      colorHex: _selectedColorNotifier.value,
    );

    if (!mounted) return;

    if (!success) {
      setSheetState(() => _nameError = 'Gagal menambahkan mood');
      return;
    }

    if (!sheetContext.mounted) return;

    HapticService.mediumImpact();
    Navigator.pop(sheetContext);
    _showSnackBar(AppLocalizations.of(context)!.moodAdded);
  }

  void _confirmArchiveMood(CustomMood mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.archiveMoodTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.archiveMoodDesc,
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
              HapticService.heavyImpact();
              await _repository.archiveCustomMood(mood);
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSnackBar(AppLocalizations.of(context)!.moodArchived);
            },
            child: Text(
              AppLocalizations.of(context)!.archive,
              style: TextStyle(color: AppColors.systemBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(CustomMood mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deletePermanentTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deletePermanentDesc,
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
              HapticService.heavyImpact();
              await _repository.deleteCustomMood(mood);
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSnackBar(AppLocalizations.of(context)!.moodDeletedPermanent);
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
            // ==========================================
            // KONTEN UTAMA
            // ==========================================
            ValueListenableBuilder(
              valueListenable: _repository.listenable,
              builder: (context, box, _) {
                final moods = _repository.getAllCustomMoods();
                final archivedMoods = _repository.getArchivedMoods();

                return ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 85,
                    bottom: 100,
                  ),
                  children: [
                    // === DESKRIPSI ===
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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

                    // === SECTION: MOOD KUSTOM ===
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
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
                    ),
                    if (moods.isEmpty)
                      _buildEmptyState()
                    else
                      _buildGroupCard(
                        moods.map((m) => _buildMoodItem(m)).toList(),
                      ),
                    const SizedBox(height: 32),

                    // === SECTION: ARSIP ===
                    if (archivedMoods.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: SectionTitle(
                          title: AppLocalizations.of(context)!.archive,
                        ),
                      ),
                      _buildGroupCard(
                        archivedMoods
                            .map((m) => _buildMoodItem(m, isArchived: true))
                            .toList(),
                      ),
                    ],
                  ],
                );
              },
            ),

            // ==========================================
            // FLOATING HEADER (Back + Pill Judul + Tombol +)
            // ==========================================
            CustomFloatingHeader(
              onBack: () => Navigator.pop(context),
              title: HeaderTitlePill(
                child: Text(
                  AppLocalizations.of(context)!.manageMoods,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              rightWidget: FloatingHeaderAction(
                icon: Icons.add,
                onTap: _showAddMoodSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER: GROUP CARD
  // ==========================================
  Widget _buildGroupCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SettingsGroupCard(children: children),
    );
  }

  // ==========================================
  // ITEM MOOD (di dalam group card)
  // ==========================================
  Widget _buildMoodItem(CustomMood mood, {bool isArchived = false}) {
    final color = isArchived
        ? AppColors.textSecondary
        : _hexToColor(mood.colorHex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Ikon mood
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.mood_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 16),

          // Nama mood
          Expanded(
            child: Text(
              mood.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isArchived
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Tombol aksi
          if (isArchived) ...[
            GestureDetector(
              onTap: () async {
                HapticService.selectionClick();
                await _repository.restoreCustomMood(mood);
                if (!mounted) return;
                _showSnackBar(AppLocalizations.of(context)!.moodRestored);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.restore,
                  color: AppColors.systemBlue,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                _confirmPermanentDelete(mood);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_forever,
                  color: AppColors.systemRed,
                  size: 20,
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                _confirmArchiveMood(mood);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.archive_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                _confirmPermanentDelete(mood);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_forever,
                  color: AppColors.systemRed,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SettingsGroupCard(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noCustomMoods,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER: HEX TO COLOR
  // ==========================================
  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('0x', '').replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  // ==========================================
  // SNACKBAR
  // ==========================================
  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }
}
