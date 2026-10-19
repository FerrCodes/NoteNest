import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Sesuaikan path import ini dengan struktur folder-mu
import 'top_banner.dart' show BannerType;

class BottomBanner {
  static OverlayEntry? _currentEntry;

  /// Tampilkan banner dari bawah layar
  static void show(
    BuildContext context, {
    required String message,
    BannerType type = BannerType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    _dismiss();

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _BottomBannerWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: _dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _BottomBannerWidget extends StatefulWidget {
  final String message;
  final BannerType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _BottomBannerWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_BottomBannerWidget> createState() => _BottomBannerWidgetState();
}

class _BottomBannerWidgetState extends State<_BottomBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animasi muncul dari BAWAH (Offset y = 1.0 ke 0.0)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _timer = Timer(widget.duration, () => _dismissAnimated());
  }

  Future<void> _dismissAnimated() async {
    if (!mounted) return;
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case BannerType.success:
        return Icons.check_circle;
      case BannerType.error:
        return Icons.cancel;
      case BannerType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case BannerType.success:
        return const Color(0xFF34C759);
      case BannerType.error:
        return const Color(0xFFFF3B30);
      case BannerType.info:
        return const Color(0xFF0A84FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 27,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            // Padding disesuaikan agar berada di atas Navigation Bar
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 20),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                HapticFeedback.lightImpact();
                _timer?.cancel();
                widget.onDismiss();
              },
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _dismissAnimated();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Agar kotak menyesuaikan teks
                    children: [
                      Icon(_getIcon(), color: _getIconColor(), size: 22),
                      const SizedBox(width: 12),
                      Flexible(
                        // Gunakan Flexible, bukan Expanded, agar teks pendek tetap di tengah
                        child: RichText(
                          text: TextSpan(
                            text: widget.message,
                            style: const TextStyle(
                              color: Color(0xFFF2F2F7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
