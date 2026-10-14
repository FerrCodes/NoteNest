import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../screens/permissions_screen.dart';
import '../utils/slide_route.dart';

/// Helper untuk cek izin + minta izin.
/// Kalau izin "permanently denied", tampilkan dialog + navigate ke halaman Izin.
///
/// Return: `true` kalau izin diberikan, `false` kalau tidak.
Future<bool> checkPermissionWithDialog(
  BuildContext context,
  Permission permission,
) async {
  final status = await permission.status;

  // Sudah granted → langsung return true
  if (status.isGranted) return true;

  // Permanently denied → dialog + navigate ke halaman Izin
  if (status.isPermanentlyDenied) {
    if (!context.mounted) return false;
    final open = await _showPermanentlyDeniedDialog(context);
    if (open == true && context.mounted) {
      Navigator.push(context, SlideRoute(page: const PermissionsScreen()));
    }
    return false;
  }

  // Denied atau Not Requested → minta izin (dialog native)
  final result = await permission.request();
  return result.isGranted;
}

/// Dialog "Izin Diblokir"
Future<bool?> _showPermanentlyDeniedDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.systemRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.block, color: AppColors.systemRed, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.permissionBlockedTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        l10n.permissionBlockedDesc,
        style: TextStyle(
          color: AppColors.textSecondary,
          height: 1.6,
          fontSize: 13,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            l10n.openPermissionPage,
            style: TextStyle(
              color: AppColors.systemBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
