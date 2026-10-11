import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/journal_entry.dart';
import 'write_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'photo_viewer_screen.dart';
import '../utils/slide_route.dart';

class DetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Color bgColor = const Color(0xFF121212);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color cardColor = const Color(0xFF1E1E1E);

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

  int _getWordCount(String content) {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  int _getReadingTime(int wordCount) {
    if (wordCount == 0) return 1;
    return (wordCount / 200).ceil(); // 200 kata/menit
  }

  String _formatRelativeTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 30) return l10n.daysAgo(diff.inDays);
    if (diff.inDays < 365) return l10n.monthsAgo((diff.inDays / 30).floor());
    return l10n.yearsAgo((diff.inDays / 365).floor());
  }

  String _formatFullDate(String dateStr) {
    // Coba parsing dengan format baru (ada jam)
    try {
      final dt = DateFormat('MMM d, yyyy HH:mm').parse(dateStr);
      final formatted = DateFormat('d MMMM yyyy', 'id_ID').format(dt);
      final time = DateFormat('HH.mm').format(dt);
      return '$formatted - $time';
    } catch (_) {}

    // Coba parsing dengan format lama (tanpa jam)
    try {
      final dt = DateFormat('MMM d, yyyy').parse(dateStr);
      final formatted = DateFormat('d MMMM yyyy', 'id_ID').format(dt);
      return formatted;
    } catch (_) {}

    // Kalau gagal parsing, kembalikan teks asli
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // === LAPISAN 1: KONTEN ===
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === 1. JUDUL & TANGGAL DI ATAS ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tanggal + Badge Mood
                        Row(
                          children: [
                            Text(
                              _formatFullDate(entry.date),
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: textSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getLocalizedMood(context, entry.mood),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Judul
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // === READING TIME & WORD COUNT ===
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.readingTime(
                                _getReadingTime(_getWordCount(entry.content)),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.text_fields,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.wordCount(_getWordCount(entry.content)),
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // === 2. GAMBAR DI TENGAH ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhotoViewerScreen(imagePath: entry.imageUrl),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            _buildImage(entry.imageUrl, height: 300),
                            // Ikon zoom di pojok kanan bawah (opsional)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.zoom_out_map,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // === 3. ISI JURNAL DI BAWAH GAMBAR ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Isi Jurnal
                        Text(
                          entry.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: textPrimary.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),

                        // === WAKTU DIEDIT ===
                        if (entry.lastEdited != null) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.editedTime(
                                  _formatRelativeTime(
                                    context,
                                    entry.lastEdited!,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary.withValues(alpha: 0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // === LAPISAN 2: TOMBOL MELAYANG ===
            Positioned(
              top: 20,
              left: 20,
              child: _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _buildCircleButton(
                label: AppLocalizations.of(context)!.edit,
                onTap: () async {
                  // Buka halaman edit
                  await Navigator.push(
                    context,
                    SlideRoute(page: WriteScreen(entry: entry)),
                  );
                  // Setelah edit selesai, refresh halaman detail
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
            // === PILL JUDUL DI TENGAH ATAS ===
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.9),
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
                    AppLocalizations.of(context)!.journalDetail,
                    style: TextStyle(
                      color: textPrimary,
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

  Widget _buildCircleButton({
    IconData? icon, // <-- opsional
    required VoidCallback onTap,
    String? label,
  }) {
    final isLabeled = label != null;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: isLabeled
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.9),
          shape: isLabeled ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isLabeled ? BorderRadius.circular(20) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isLabeled
            ? Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: textPrimary, size: 20),
      ),
    );
  }

  Widget _buildImage(
    String imagePath, {
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // 1. URL internet
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: height,
        width: double.infinity,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            color: cardColor,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textSecondary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: cardColor,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: textSecondary,
                size: 40,
              ),
            ),
          );
        },
      );
    }
    // 2. Asset lokal (preset gambar)
    else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }
    // 3. File lokal (foto dari galeri/kamera)
    else {
      return Image.file(
        File(imagePath),
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }
  }
}
