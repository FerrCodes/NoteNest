import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/haptic_service.dart';

class CustomFloatingHeader extends StatelessWidget {
  final Widget title;
  final VoidCallback? onBack;
  final Widget? rightWidget;

  const CustomFloatingHeader({
    super.key,
    required this.title,
    this.onBack,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Menggunakan MediaQuery agar otomatis menyesuaikan status bar HP
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: Tombol Back (atau Spacer jika tidak ada)
          if (onBack != null)
            FloatingHeaderAction(icon: Icons.arrow_back_ios_new, onTap: onBack!)
          else
            const SizedBox(width: 48), // 48 adalah ukuran pas tombol back
          // Tengah: Judul Pill
          Expanded(child: Center(child: title)),

          // Kanan: Tombol Kanan (atau Spacer jika tidak ada)
          if (rightWidget != null)
            rightWidget!
          else
            const SizedBox(width: 48), // Spacer yang sama persis
        ],
      ),
    );
  }
}

// Widget Tombol Bulat/Pill Standar
class FloatingHeaderAction extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String? label;
  final Color? labelColor;
  final VoidCallback onTap;

  const FloatingHeaderAction({
    super.key,
    this.icon,
    this.customIcon,
    this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLabeled = label != null;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onTap();
      },
      child: Container(
        height: 48, // Kunci tinggi 48px
        width: isLabeled ? null : 48, // Kunci lebar 48px untuk bulat
        padding: isLabeled ? const EdgeInsets.symmetric(horizontal: 16) : null,
        decoration: BoxDecoration(
          color: AppColors.cardDark.withValues(alpha: 0.9),
          shape: isLabeled ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isLabeled ? BorderRadius.circular(20) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLabeled
              ? Text(
                  label!,
                  style: TextStyle(
                    color: labelColor ?? AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : (customIcon ??
                    Icon(icon, color: AppColors.textPrimary, size: 20)),
        ),
      ),
    );
  }
}

// Widget Pill Judul Standar
class HeaderTitlePill extends StatelessWidget {
  final Widget child;
  const HeaderTitlePill({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      child: child,
    );
  }
}
