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

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});
  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  // State untuk pencarian & filter
  String _searchQuery = '';
  String? _selectedMoodFilter; // null = tampilkan semua

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

  final TextEditingController _searchController = TextEditingController();
  final _repository = JournalRepository();
  @override
  void dispose() {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      AppLocalizations.of(context)!.reflect,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterAll,
                            isSelected: _selectedMoodFilter == null,
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterFavorite,
                            isSelected: _selectedMoodFilter == 'FAVORITE',
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = 'FAVORITE';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterCalm,
                            isSelected: _selectedMoodFilter == 'Calm',
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = 'Calm';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterGrateful,
                            isSelected: _selectedMoodFilter == 'Grateful',
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = 'Grateful';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterPeaceful,
                            isSelected: _selectedMoodFilter == 'Peaceful',
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = 'Peaceful';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          MoodFilterChip(
                            label: AppLocalizations.of(context)!.filterFocused,
                            isSelected: _selectedMoodFilter == 'Focused',
                            onTap: () {
                              setState(() {
                                _selectedMoodFilter = 'Focused';
                              });
                            },
                          ),
                        ],
                      ),
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
}
