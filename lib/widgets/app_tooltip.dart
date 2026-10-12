import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool preferBelow;

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: const Duration(milliseconds: 400),
      showDuration: const Duration(seconds: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Sesuai versi kamu
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      child: child,
    );
  }
}
