import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../constants/moods.dart';
import '../repositories/mood_repository.dart';
import '../widgets/custom_floating_header.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _moodRepository = MoodRepository();

  // === HELPER: HEX TO COLOR ===
  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('0x', '').replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  // === HELPER: LOCALIZED MOOD ===
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
    final box = Hive.box<JournalEntry>('journalBox');

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA ===
            ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<JournalEntry> box, _) {
                final entries = box.values.toList();

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.noDataTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.noDataDesc,
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

                // === HITUNG DATA ===
                final totalEntries = entries.length;

                // Gabungkan preset + custom mood
                final allMoods = <Map<String, dynamic>>[
                  ...MoodPresets.all,
                  ..._moodRepository.getAllCustomMoods().map(
                    (m) => {
                      'label': m.label,
                      'icon': Icons.mood_outlined,
                      'color': _hexToColor(m.colorHex),
                      'isCustom': true,
                    },
                  ),
                ];

                // Hitung jumlah per mood (hanya yang ada jurnalnya)
                final moodCounts = <String, int>{};
                for (var mood in allMoods) {
                  final count = entries
                      .where((e) => e.mood == mood['label'])
                      .length;
                  if (count > 0) {
                    moodCounts[mood['label']] = count;
                  }
                }

                String topMood = '';
                int topCount = 0;
                moodCounts.forEach((mood, count) {
                  if (count > topCount) {
                    topCount = count;
                    topMood = mood;
                  }
                });

                final now = DateTime.now();
                final weekAgo = now.subtract(const Duration(days: 7));
                final thisWeekCount = entries.where((e) {
                  final d = _parseDate(e.date);
                  return d != null && d.isAfter(weekAgo);
                }).length;

                final streak = _calculateStreak(entries);

                final nowMonth = DateTime.now().month;
                final nowYear = DateTime.now().year;
                final entriesThisMonth = entries.where((e) {
                  final d = _parseDate(e.date);
                  return d != null && d.month == nowMonth && d.year == nowYear;
                }).toList();

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16, // kiri
                    MediaQuery.of(context).padding.top + 85,
                    16,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === STREAK CARD ===
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.systemYellow.withValues(alpha: 0.2),
                              AppColors.cardDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.systemYellow.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.systemYellow.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$streak ${AppLocalizations.of(context)!.days}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  streak == 0
                                      ? AppLocalizations.of(
                                          context,
                                        )!.startStreak
                                      : AppLocalizations.of(
                                          context,
                                        )!.streakDesc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === KARTU RINGKASAN ===
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.auto_stories_outlined,
                              value: '$totalEntries',
                              label: AppLocalizations.of(
                                context,
                              )!.totalJournals,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.calendar_today_outlined,
                              value: '$thisWeekCount',
                              label: AppLocalizations.of(context)!.thisWeek,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // === MOOD TERBANYAK ===
                      Text(
                        AppLocalizations.of(context)!.topMood,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                MoodPresets.getIcon(topMood) ??
                                    Icons.mood_outlined,
                                color: AppColors.textPrimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topMood,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.journalsWithMood(topCount),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // === KALENDER MINI ===
                      Text(
                        AppLocalizations.of(context)!.thisMonth,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _buildMiniCalendar(context, entriesThisMonth),
                      ),
                      const SizedBox(height: 32),

                      // === GRAFIK MINGGUAN ===
                      Text(
                        AppLocalizations.of(context)!.weeklyChart,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          height: 160,
                          child: _buildWeeklyChart(entries),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // === GRAFIK MOOD ===
                      Text(
                        AppLocalizations.of(context)!.moodDistribution,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SizedBox(
                          height: 220,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              // Lebar dinamis: 60px per mood, minimal selebar container
                              width: allMoods.length * 64.0,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: moodCounts.isEmpty
                                      ? 5.0
                                      : (moodCounts.values.reduce(
                                                  (a, b) => a > b ? a : b,
                                                ) +
                                                1)
                                            .toDouble(),
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize:
                                            50, // <-- Ruang ekstra untuk label
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index < allMoods.length) {
                                            final mood = allMoods[index];
                                            final label =
                                                mood['label'] as String;
                                            final isCustom =
                                                mood['isCustom'] == true;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: SizedBox(
                                                width:
                                                    56, // <-- Batasi lebar label
                                                child: Text(
                                                  isCustom
                                                      ? label
                                                      : _getLocalizedMood(
                                                          context,
                                                          label,
                                                        ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(allMoods.length, (
                                    index,
                                  ) {
                                    final mood = allMoods[index];
                                    final label = mood['label'] as String;
                                    final count = moodCounts[label] ?? 0;
                                    final color =
                                        mood['color'] as Color? ??
                                        AppColors.textPrimary;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: count.toDouble(),
                                          color: color,
                                          width: 24,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),

            // === FLOATING HEADER (Back + Pill Judul) ===
            CustomFloatingHeader(
              onBack: () => Navigator.pop(context),
              title: HeaderTitlePill(
                child: Text(
                  AppLocalizations.of(context)!.stats,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === HELPER: PARSE DATE (ANTI GAGAL) ===
  DateTime? _parseDate(String dateStr) {
    // 1. Coba parsing format baru (ISO 8601)
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    // 2. Fallback: Coba parsing format lama (bisa jadi locale id atau en)
    try {
      return DateFormat('MMM d, yyyy HH:mm', 'id_ID').parse(dateStr);
    } catch (_) {}

    try {
      return DateFormat('MMM d, yyyy', 'id_ID').parse(dateStr);
    } catch (_) {}

    try {
      return DateFormat('MMM d, yyyy HH:mm', 'en_US').parse(dateStr);
    } catch (_) {}

    try {
      return DateFormat('MMM d, yyyy', 'en_US').parse(dateStr);
    } catch (_) {}

    // Jika semua gagal, kembalikan null
    return null;
  }

  // === HELPER: HITUNG STREAK ===
  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    final Set<DateTime> uniqueDays = {};
    for (var entry in entries) {
      final d = _parseDate(entry.date);
      if (d != null) {
        uniqueDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    if (uniqueDays.isEmpty) return 0;

    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (sortedDays.first != todayDate && sortedDays.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDays.length - 1; i++) {
      final diff = sortedDays[i].difference(sortedDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // === HELPER: KALENDER MINI ===
  Widget _buildMiniCalendar(
    BuildContext context,
    List<JournalEntry> entriesThisMonth,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday;

    final Set<int> daysWithEntries = {};
    for (var entry in entriesThisMonth) {
      final d = _parseDate(entry.date);
      if (d != null) daysWithEntries.add(d.day);
    }

    final dayLabelsOrdered = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    // Nama bulan ini (contoh: "September 2026")
    final currentLocale = Localizations.localeOf(context).toString();
    final monthName = DateFormat('MMMM yyyy', currentLocale).format(now);

    return Column(
      children: [
        // Judul bulan
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            monthName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabelsOrdered.map((day) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: (startWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday - 1) {
              return const SizedBox();
            }
            final day = index - (startWeekday - 1) + 1;
            final hasEntry = daysWithEntries.contains(day);
            final isToday = day == now.day;

            return Container(
              decoration: BoxDecoration(
                color: hasEntry ? AppColors.textPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !hasEntry
                    ? Border.all(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasEntry || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: hasEntry
                        ? AppColors.bgDark
                        : (isToday
                              ? AppColors.textPrimary
                              : AppColors.textSecondary),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // === HELPER: GRAFIK MINGGUAN ===
  Widget _buildWeeklyChart(List<JournalEntry> entries) {
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day - (6 - i));
    });

    final List<int> counts = last7Days.map((day) {
      return entries.where((e) {
        final d = _parseDate(e.date);
        if (d == null) return false;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    }).toList();

    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < last7Days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dayNames[last7Days[index].weekday - 1],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(last7Days.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: counts[index].toDouble(),
                color: counts[index] > 0
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
