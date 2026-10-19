import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/preset_images.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../screens/photo_viewer_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../services/haptic_service.dart';

class ImagePickerSection extends StatelessWidget {
  final List<String> selectedImages;
  final ValueChanged<List<String>> onImagesChanged;

  const ImagePickerSection({
    super.key,
    required this.selectedImages,
    required this.onImagesChanged,
  });

  static const int maxPhotos = 4;

  @override
  Widget build(BuildContext context) {
    final canAddMore = selectedImages.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === SECTION LABEL: PRESET GAMBAR ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.selectImage.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${selectedImages.length}/$maxPhotos',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // === PRESET GAMBAR (FULL-WIDTH SCROLL) ===
        // Tidak ada Padding di sini — biar scroll sampai tepi layar
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // padding di DALAM ListView
            itemCount: PresetImages.images.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final img = PresetImages.images[index];
              final isSelected = selectedImages.contains(img['url']);
              return GestureDetector(
                onTap: () {
                  HapticService.selectionClick();
                  final url = img['url']!;
                  final newList = List<String>.from(selectedImages);
                  if (isSelected) {
                    newList.remove(url);
                  } else {
                    if (newList.length >= maxPhotos) {
                      _showMaxPhotosSnackBar(context);
                      return;
                    }
                    newList.add(url);
                  }
                  onImagesChanged(newList);
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

        // === SECTION LABEL: UNGGAH FOTO ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.uploadPhoto.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // === TOMBOL UNGGAH ===
        if (canAddMore)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                _showImageSourceSheet(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
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
          ),

        // === PREVIEW FOTO TERPILIH ===
        if (selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedImages.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final imagePath = selectedImages[index];
                return GestureDetector(
                  onTap: () {
                    HapticService.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoViewerScreen(imagePath: imagePath),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: _buildImage(imagePath),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              HapticService.selectionClick();
                              final newList = List<String>.from(selectedImages);
                              newList.removeAt(index);
                              onImagesChanged(newList);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // === HELPER: BUILD IMAGE ===
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.cover, cacheWidth: 360);
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover, cacheWidth: 360);
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        cacheWidth: 360,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      );
    }
  }

  // === BOTTOM SHEET: SUMBER FOTO ===
  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                _buildSourceOption(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: AppLocalizations.of(context)!.cameraOption,
                  subtitle: AppLocalizations.of(context)!.cameraOptionDesc,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, fromCamera: true);
                  },
                ),
                const SizedBox(height: 10),
                _buildSourceOption(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: AppLocalizations.of(context)!.galleryOption,
                  subtitle: AppLocalizations.of(context)!.galleryOptionDesc,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, fromCamera: false);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    // Cek izin dulu
    final permission = fromCamera ? Permission.camera : Permission.photos;
    final granted = await checkPermissionWithDialog(context, permission);

    if (!granted) return;
    if (!context.mounted) return;

    try {
      final ImagePicker picker = ImagePicker();

      // === LOGIKA BARU ===
      if (fromCamera) {
        // Jika dari Kamera, tetap satu foto
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1920,
        );

        if (pickedFile != null) {
          if (!context.mounted) return;
          HapticService.mediumImpact();
          final newList = List<String>.from(selectedImages);
          if (newList.length >= maxPhotos) {
            _showMaxPhotosSnackBar(context);
            return;
          }
          newList.add(pickedFile.path);
          onImagesChanged(newList);
        }
      } else {
        // Jika dari Galeri, gunakan pickMultiImage (Pilih Banyak)
        final List<XFile> pickedFiles = await picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1080,
          maxHeight: 1920,
        );

        if (pickedFiles.isNotEmpty) {
          if (!context.mounted) return;
          HapticService.mediumImpact();

          final newList = List<String>.from(selectedImages);

          for (var file in pickedFiles) {
            // Cek apakah kuota foto sudah penuh (maksimal 4)
            if (newList.length >= maxPhotos) {
              _showMaxPhotosSnackBar(context);
              break; // Hentikan perulangan jika sudah penuh
            }
            newList.add(file.path);
          }

          onImagesChanged(newList);
        }
      }
      // ===================
    } catch (e) {
      HapticService.heavyImpact();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 90, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  void _showMaxPhotosSnackBar(BuildContext context) {
    HapticService.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Maksimal $maxPhotos foto per jurnal'),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 90, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
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
