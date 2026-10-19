import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../services/haptic_service.dart';

class PhotoViewerScreen extends StatefulWidget {
  final String imagePath;
  final List<String>? allPhotos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.imagePath,
    this.allPhotos,
    this.initialIndex = 0,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<String> _photos;
  bool _showControls = true;

  // Satu scale controller per foto, dipakai untuk tombol reset zoom
  final Map<int, PhotoViewScaleStateController> _scaleControllers = {};

  PhotoViewScaleStateController _scaleControllerFor(int index) {
    return _scaleControllers.putIfAbsent(
      index,
      () => PhotoViewScaleStateController(),
    );
  }

  @override
  void initState() {
    super.initState();

    _photos = widget.allPhotos ?? [widget.imagePath];
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _scaleControllers.values) {
      c.dispose();
    }

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  ImageProvider _providerFor(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets/')) return AssetImage(path);
    return FileImage(File(path));
  }

  // Double tap: normal -> zoom in, zoom in -> normal (seperti Galeri Samsung)
  PhotoViewScaleState _cycle(PhotoViewScaleState actual) {
    return actual == PhotoViewScaleState.initial
        ? PhotoViewScaleState.covering
        : PhotoViewScaleState.initial;
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = _photos.length > 1;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // === GALERI FOTO ===
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: _photos.length,
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // Foto yang ditinggalkan dikembalikan ke ukuran normal
              _scaleControllers.forEach((i, c) {
                if (i != index) c.reset();
              });
            },
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: _providerFor(_photos[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                scaleStateController: _scaleControllerFor(index),
                scaleStateCycle: _cycle,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'photo_${_photos[index]}',
                ),
                // Tap sekali: tampil/sembunyikan tombol, seperti Galeri Samsung
                onTapUp: (context, details, controllerValue) {
                  setState(() => _showControls = !_showControls);
                },
              );
            },
          ),

          // === TOMBOL-TOMBOL (hilang saat tap layar) ===
          AnimatedOpacity(
            opacity: _showControls ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Stack(
                children: [
                  // Tombol close (kiri atas)
                  Positioned(
                    top: topPadding + 12,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Indikator foto (tengah atas)
                  if (hasMultiple)
                    Positioned(
                      top: topPadding + 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${_photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tombol reset zoom (kanan atas)
                  Positioned(
                    top: topPadding + 12,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        _scaleControllerFor(_currentIndex).reset();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
