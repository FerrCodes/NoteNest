import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class SettingItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingItem({
    super.key,
    this.icon,
    this.customIcon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ikon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.systemRed.withValues(alpha: 0.15)
                    : AppColors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  customIcon ??
                  Icon(
                    icon,
                    color: isDestructive
                        ? AppColors.systemRed
                        : AppColors.textPrimary,
                    size: 20,
                  ),
            ),
            const SizedBox(width: 16),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.systemRed
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            if (!isDestructive)
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
