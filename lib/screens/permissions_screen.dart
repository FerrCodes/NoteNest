import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_group_card.dart';
import '../services/haptic_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  Map<String, PermissionStatus> _statuses = {};
  bool _isLoading = true;

  final List<String> _permissionKeys = [
    'notification',
    'location',
    'camera',
    'gallery',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissionStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatuses();
    }
  }

  Future<void> _loadPermissionStatuses() async {
    final Map<String, PermissionStatus> statuses = {};

    statuses['notification'] = await Permission.notification.status;
    statuses['location'] = await Permission.locationWhenInUse.status;
    statuses['camera'] = await Permission.camera.status;
    statuses['gallery'] = await Permission.photos.status;

    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _isLoading = false;
    });
  }

  Future<void> _handleTap(String key) async {
    HapticService.selectionClick();
    // Semua tap → buka Settings HP (App Info)
    await openAppSettings();
  }

  String _getTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'notification':
        return l10n.permissionNotification;
      case 'location':
        return l10n.permissionLocation;
      case 'camera':
        return l10n.permissionCamera;
      case 'gallery':
        return l10n.permissionGallery;
      default:
        return key;
    }
  }

  String _getDesc(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'notification':
        return l10n.permissionNotificationDesc;
      case 'location':
        return l10n.permissionLocationDesc;
      case 'camera':
        return l10n.permissionCameraDesc;
      case 'gallery':
        return l10n.permissionGalleryDesc;
      default:
        return '';
    }
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'notification':
        return Icons.notifications_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'gallery':
        return Icons.photo_library_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _statusLabel(BuildContext context, PermissionStatus status) {
    final l10n = AppLocalizations.of(context)!;
    if (status.isGranted) return l10n.permissionStatusGranted;
    if (status.isRestricted) return l10n.permissionStatusRestricted;
    if (status.isDenied) return l10n.permissionStatusDenied;
    return l10n.permissionStatusNotRequested;
  }

  Color _statusColor(PermissionStatus status) {
    if (status.isGranted) return AppColors.systemGreen;
    if (status.isRestricted) return AppColors.systemYellow;
    return AppColors.systemRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                bottom: 24,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context)!.permissionsDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SectionTitle(
                    title: AppLocalizations.of(context)!.permissionsListSection,
                  ),
                ),

                _buildGroupCard(),

                // === FOOTER HINT ===
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.permissionTapToOpen,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.permissionSamsungHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
                        child: Text(
                          AppLocalizations.of(context)!.permissionsTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 47),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SettingsGroupCard(
        children: _permissionKeys
            .map((key) => _buildPermissionItem(key))
            .toList(),
      ),
    );
  }

  Widget _buildPermissionItem(String key) {
    final status = _statuses[key];
    final label = _getTitle(context, key);
    final subtitle = _getDesc(context, key);
    final icon = _getIcon(key);

    return GestureDetector(
      onTap: _isLoading ? null : () => _handleTap(key),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
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
            if (_isLoading || status == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusLabel(context, status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(status),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
