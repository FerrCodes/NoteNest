import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();

    // Kalau allPhotos tidak ada, berarti cuma 1 foto
    _photos = widget.allPhotos ?? [widget.imagePath];
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Set style status bar (ikon putih di background hitam)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
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

  @override
  Widget build(BuildContext context) {
    final hasMultiple = _photos.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // === CAROUSEL FOTO ===
          PageView.builder(
            controller: _pageController,
            itemCount: _photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Tap untuk keluar (opsional)
                  Navigator.pop(context);
                },
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: _buildImage(_photos[index]),
                  ),
                ),
              );
            },
          ),

          // === TOMBOL CLOSE (KIRI ATAS) ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // === INDIKATOR FOTO (TENGAH ATAS) ===
          if (hasMultiple)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
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

          // === TOMBOL RESET ZOOM (KANAN ATAS) ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                // Reset zoom di semua page
                setState(() {
                  _pageController.jumpToPage(_currentIndex);
                });
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
    );
  }

  // === BUILD IMAGE ===
  Widget _buildImage(String imagePath) {
    // URL internet
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );
    }
    // Asset
    else if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.contain);
    }
    // File lokal
    else {
      return Image.file(File(imagePath), fit: BoxFit.contain);
    }
  }
}
