import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../utils/preset_images.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class ImagePickerSection extends StatelessWidget {
  final String selectedImage;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final ValueChanged<String> onImageSelected;

  const ImagePickerSection({
    super.key,
    required this.selectedImage,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === KATEGORI 1: PRESET GAMBAR ===
        Text(
          AppLocalizations.of(context)!.selectImage,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PresetImages.images.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final img = PresetImages.images[index];
              final isSelected = selectedImage == img['url'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onImageSelected(img['url']!);
                },
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(img['url']!, fit: BoxFit.cover),
                        if (isSelected)
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // === KATEGORI 2: UPLOAD DARI GALERI/KAMERA ===
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.uploadPhoto,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _showPhotoTipsDialog(context);
              },
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onPickFromGallery,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: !selectedImage.startsWith('assets/')
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.galleryOption,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.galleryOptionDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onPickFromCamera,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.cameraOption,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.cameraOptionDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // === PREVIEW FOTO YANG DIPILIH ===
        if (!selectedImage.startsWith('assets/')) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (selectedImage.startsWith('http'))
                  Image.network(
                    selectedImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else
                  Image.file(
                    File(selectedImage),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onImageSelected(PresetImages.getDefault());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // === DIALOG TIPS FOTO ===
  void _showPhotoTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.tips_and_updates_outlined,
              color: Color(0xFFFFD60A),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.photoTipsTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.photoTipsDesc,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRatioExample('16:9', 80, 45, '✓'),
                _buildRatioExample('1:1', 60, 60, '✓'),
                _buildRatioExample('9:16', 45, 80, '✕'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.gotIt,
              style: const TextStyle(
                color: Color(0xFF0A84FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioExample(String label, double w, double h, String mark) {
    return Column(
      children: [
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            border: Border.all(
              color: mark == '✓'
                  ? AppColors.systemGreen.withValues(alpha: 0.6)
                  : AppColors.systemRed.withValues(alpha: 0.6),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              mark,
              style: TextStyle(
                color: mark == '✓'
                    ? AppColors.systemGreen
                    : AppColors.systemRed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
