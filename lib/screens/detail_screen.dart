import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/journal_entry.dart';
import 'write_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'photo_viewer_screen.dart';
import '../utils/slide_route.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
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
      backgroundColor: AppColors.bgDark,
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
                    padding: const EdgeInsets.fromLTRB(16, 85, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tanggal + Badge Mood
                        Row(
                          children: [
                            Text(
                              _formatFullDate(entry.date),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
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
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getLocalizedMood(context, entry.mood),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // === READING TIME & WORD COUNT ===
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.readingTime(
                                _getReadingTime(_getWordCount(entry.content)),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.text_fields,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.wordCount(_getWordCount(entry.content)),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Judul
                        Text(
                          entry.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // === 2. GAMBAR DI TENGAH ===
                  // === CAROUSEL FOTO ===
                  if (entry.imageUrls.isNotEmpty)
                    _buildPhotoCarousel(context, entry),

                  // === 3. ISI JURNAL DI BAWAH GAMBAR ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Isi Jurnal
                        Text(
                          entry.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
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
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
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
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
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

            // === FLOATING HEADER (Back + Pill Judul + Edit) ===
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol Back
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),

                  // Pill Judul (Expanded agar mengisi ruang tengah)
                  Expanded(
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
                          AppLocalizations.of(context)!.journalDetail,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Edit
                  _buildCircleButton(
                    label: AppLocalizations.of(context)!.edit,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        SlideRoute(page: WriteScreen(entry: entry)),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCarousel(BuildContext context, JournalEntry entry) {
    final photos = entry.imageUrls;

    // Kalau cuma 1 foto, tampilkan seperti biasa (tanpa carousel)
    if (photos.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewerScreen(
                  imagePath: photos.first,
                  allPhotos: photos,
                  initialIndex: 0,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _buildImage(photos.first, height: 300),
          ),
        ),
      );
    }

    // Kalau lebih dari 1 foto, tampilkan sebagai carousel
    return SizedBox(
      height: 370,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        pageSnapping: false,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 7,
              right: index == photos.length - 0 ? 0 : 7,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewerScreen(
                      imagePath: photos[index],
                      allPhotos: photos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: _buildImage(photos[index], height: 300),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    IconData? icon,
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
            : const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark.withValues(alpha: 0.9),
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
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: AppColors.textPrimary, size: 19),
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
            color: AppColors.cardDark,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: AppColors.cardDark,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textSecondary,
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
