import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../l10n/app_localizations.dart';
import 'detail_screen.dart';
import 'write_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/top_banner.dart';
import '../widgets/journal_card.dart';
import '../widgets/mood_filter_chip.dart';
import '../repositories/journal_repository.dart';
import '../utils/slide_route.dart';
import '../theme/app_colors.dart';
import '../repositories/mood_repository.dart';
import '../constants/moods.dart';
import 'manage_moods_screen.dart';
import '../widgets/app_tooltip.dart';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});
  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  // State untuk pencarian & filter
  String _searchQuery = '';
  final _moodRepository = MoodRepository();
  final GlobalKey<_AnimatedDropdownState> _dropdownKey = GlobalKey();
  String? _selectedMoodFilter;
  OverlayEntry? _dropdownOverlay;
  bool _isDropdownOpen = false;

  String _getTimeBasedQuote(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return l10n.quoteMorning; // 05:00 - 11:59
    } else if (hour >= 12 && hour < 18) {
      return l10n.quoteAfternoon; // 12:00 - 17:59
    } else if (hour >= 18 && hour < 22) {
      return l10n.quoteEvening; // 18:00 - 21:59
    } else {
      return l10n.quoteNight; // 22:00 - 04:59
    }
  }

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

  void _toggleDropdown() {
    HapticFeedback.selectionClick();

    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isDropdownOpen = true);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => _AnimatedDropdown(
        key: _dropdownKey,
        onDismiss: () {
          _dropdownOverlay?.remove();
          _dropdownOverlay = null;
          if (mounted) {
            setState(() => _isDropdownOpen = false);
          }
        },
        child: _buildDropdownMenu(),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _closeDropdown() {
    // Panggil close() dari _AnimatedDropdown agar animasi reverse jalan
    _dropdownKey.currentState?.close();
  }

  Widget _buildDropdownMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdownItem(
              icon: Icons.mood_outlined,
              label: AppLocalizations.of(context)!.manageMoods,
              onTap: () {
                _closeDropdown();
                Future.delayed(const Duration(milliseconds: 220), () {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    SlideRoute(page: const ManageMoodsScreen()),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent, // Tidak ada ripple
      highlightColor: AppColors.textPrimary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();
  final _repository = JournalRepository();
  @override
  void dispose() {
    _dropdownOverlay?.remove();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  MediaQuery.of(context).padding.top + 37.0,
                  24.0,
                  20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const SizedBox(height: 20),
                    // === KOLOM PENCARIAN ===
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: false,
                              textInputAction: TextInputAction.search,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.searchHint,
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === FILTER MOOD ===
                    ValueListenableBuilder(
                      valueListenable: _moodRepository.listenable,
                      builder: (context, box, _) {
                        final customMoods = _moodRepository.getAllCustomMoods();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Filter "All"
                              _buildFilterChip(
                                context,
                                label: AppLocalizations.of(context)!.filterAll,
                                value: null,
                              ),
                              const SizedBox(width: 8),

                              // Filter "Favorite"
                              _buildFilterChip(
                                context,
                                label: AppLocalizations.of(
                                  context,
                                )!.filterFavorite,
                                value: 'FAVORITE',
                              ),
                              const SizedBox(width: 8),

                              // Filter untuk setiap preset mood
                              ...MoodPresets.all.map((mood) {
                                final label = mood['label'] as String;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterChip(
                                    context,
                                    label: _getLocalizedMood(context, label),
                                    value: label,
                                  ),
                                );
                              }),

                              // Filter untuk setiap custom mood
                              ...customMoods.map((mood) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterChip(
                                    context,
                                    label: mood.label,
                                    value: mood.label,
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Quote berganti berdasarkan waktu
                    Text(
                      _getTimeBasedQuote(context),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Journal Card
                    Text(
                      AppLocalizations.of(context)!.todaysEntry,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJournalList(),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          // === 2. FLOATING NAVIGATION BAR ===
          Positioned(
            left: 0,
            right: 0,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withValues(
                    alpha: 0.95,
                  ), // Card color transparan
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          SlideRoute(page: const StatsScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.bar_chart_outlined,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Tombol Plus (Besar di tengah)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRoute(page: const WriteScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.bgDark,
                          size: 26,
                        ), // Ikon hitam di tombol putih
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          SlideRoute(page: const SettingsScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // === PILL JUDUL ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: AppTooltip(
                message: AppLocalizations.of(context)!.dropdownHint,
                child: GestureDetector(
                  onTap: _toggleDropdown,
                  behavior: HitTestBehavior.opaque,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.reflect,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // AnimatedSize: ukuran container menyesuaikan, jadi pill "melebar" saat chevron muncul
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          child: _isDropdownOpen
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: AnimatedRotation(
                                    turns: 0.5, // chevron menghadap ke atas
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textPrimary,
                                      size: 22,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(), // ukuran 0 saat tertutup
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return ValueListenableBuilder(
      valueListenable: _repository.listenable,
      builder: (context, Box<JournalEntry> box, _) {
        if (_repository.isEmpty()) {
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
                  AppLocalizations.of(context)!.noJournalsTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.noJournalsDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        final filteredEntries = _repository.getFilteredJournals(
          moodFilter: _selectedMoodFilter,
          searchQuery: _searchQuery,
        );

        // Kalau hasil filter kosong, tampilkan pesan
        if (filteredEntries.isEmpty) {
          // Pesan khusus untuk filter favorit
          final isEmptyFavorite = _selectedMoodFilter == 'FAVORITE';
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  isEmptyFavorite
                      ? AppLocalizations.of(context)!.noFavoritesTitle
                      : AppLocalizations.of(context)!.noResultsTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEmptyFavorite
                      ? AppLocalizations.of(context)!.noFavoritesDesc
                      : AppLocalizations.of(context)!.noResultsDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: filteredEntries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Dismissible(
                key: Key(entry.key.toString()), // Key unik per entry
                direction:
                    DismissDirection.endToStart, // Swipe dari kanan ke kiri
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.systemRed.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  // Konfirmasi sebelum hapus
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.deleteConfirmTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.deleteConfirmDesc,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            AppLocalizations.of(context)!.delete,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  HapticFeedback.heavyImpact();
                  _repository.deleteJournal(entry);
                  TopBanner.show(
                    context,
                    message: AppLocalizations.of(context)!.journalDeleted,
                    type: BannerType.success,
                  );
                },
                child: JournalCard(
                  entry: entry,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRoute(page: DetailScreen(entry: entry)),
                    );
                  },
                  onToggleFavorite: () {
                    setState(() {
                      entry.isFavorite = !entry.isFavorite;
                      entry.save();
                    });
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String? value,
  }) {
    return MoodFilterChip(
      label: label,
      isSelected: _selectedMoodFilter == value,
      onTap: () {
        setState(() {
          _selectedMoodFilter = value;
        });
      },
    );
  }
}

// Animasi
class _AnimatedDropdown extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _AnimatedDropdown({
    super.key,
    required this.child,
    required this.onDismiss,
  });

  @override
  State<_AnimatedDropdown> createState() => _AnimatedDropdownState();
}

class _AnimatedDropdownState extends State<_AnimatedDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Mulai animasi masuk
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fungsi untuk menutup dengan animasi reverse, lalu panggil onDismiss.
  Future<void> close() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay transparan untuk menangkap tap di luar
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              // Tutup dengan animasi, lalu dismiss
              close();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Dropdown dengan animasi
        Positioned(
          top: MediaQuery.of(context).padding.top + 76,
          left: 0,
          right: 0,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.topCenter,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
