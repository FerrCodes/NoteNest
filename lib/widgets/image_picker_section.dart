import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../utils/preset_images.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../screens/photo_viewer_screen.dart';

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
          AppLocalizations.of(context)!.selectImage.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
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
                        Image.asset(
                          img['url']!,
                          fit: BoxFit.cover,
                          cacheWidth: 200,
                        ),
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

        // === KATEGORI 2: UNGGAH FOTO ===
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.uploadPhoto.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // === TOMBOL UNGGAH (SINGLE BUTTON) ===
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _showImageSourceSheet(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: !selectedImage.startsWith('assets/')
                    ? AppColors.textPrimary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.uploadPhoto,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // === PREVIEW FOTO ===
        if (!selectedImage.startsWith('assets/')) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PhotoViewerScreen(imagePath: selectedImage),
                ),
              );
            },
            child: ClipRRect(
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
                  // Tombol close
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
          ),
        ],
      ],
    );
  }

  // === BOTTOM SHEET: PILIH SUMBER FOTO ===
  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
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
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.uploadPhoto,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Option: Galeri
                _buildSourceOption(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: AppLocalizations.of(context)!.galleryOption,
                  subtitle: AppLocalizations.of(context)!.galleryOptionDesc,
                  onTap: () {
                    Navigator.pop(context);
                    onPickFromGallery();
                  },
                ),
                const SizedBox(height: 8),
                // Option: Kamera
                _buildSourceOption(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: AppLocalizations.of(context)!.cameraOption,
                  subtitle: AppLocalizations.of(context)!.cameraOptionDesc,
                  onTap: () {
                    Navigator.pop(context);
                    onPickFromCamera();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // === ITEM BOTTOM SHEET ===
  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
