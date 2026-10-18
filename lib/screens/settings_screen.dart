import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import '../widgets/top_banner.dart';
import '../services/export_service.dart';
import '../widgets/section_title.dart';
import '../widgets/setting_item.dart';
import '../widgets/settings_group_card.dart';
import '../theme/app_colors.dart';
import 'about_screen.dart';
import 'guide_screen.dart';
import 'permissions_screen.dart';
import '../utils/slide_route.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  bool _isLanguageMenuOpen = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final TextEditingController _reminderMessageController =
      TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey _languageItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final settingsBox = Hive.box('settingsBox');
    final enabled = settingsBox.get('reminderEnabled', defaultValue: false);
    final hour = settingsBox.get('reminderHour', defaultValue: 20);
    final minute = settingsBox.get('reminderMinute', defaultValue: 0);
    final message = settingsBox.get(
      'reminderMessage',
      defaultValue: 'Waktunya menulis jurnal hari ini!',
    );

    setState(() {
      _reminderEnabled = enabled;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _reminderMessageController.text = message;
    });
  }

  @override
  void dispose() {
    _reminderMessageController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================
            // KONTEN UTAMA
            // ==========================================
            ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 85,
                bottom: 24,
              ),
              children: [
                // ==========================================
                // SECTION: GENERAL
                // ==========================================
                _buildSectionTitle(
                  AppLocalizations.of(context)!.generalSection,
                ),
                _buildGroupCard([
                  _buildLanguageSelector(),
                  _buildHapticToggle(),
                  _buildReminderToggle(),
                  if (_reminderEnabled) ...[
                    _buildReminderTime(),
                    _buildReminderMessage(),
                    _buildTestNotification(),
                  ],
                ]),
                const SizedBox(height: 32),

                // ==========================================
                // SECTION: APP
                // ==========================================
                _buildSectionTitle(AppLocalizations.of(context)!.appSection),
                _buildGroupCard([
                  SettingItem(
                    icon: Icons.menu_book_outlined,
                    title: AppLocalizations.of(context)!.guideTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRoute(page: const GuideScreen()),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.android,
                    title: AppLocalizations.of(context)!.permissionsTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRoute(page: const PermissionsScreen()),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.info_outline,
                    title: AppLocalizations.of(context)!.aboutApp,
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRoute(page: const AboutScreen()),
                      );
                    },
                  ),
                  SettingItem(
                    icon: Icons.mail_outline,
                    title: AppLocalizations.of(context)!.sendFeedback,
                    onTap: () {
                      _showFeedbackBottomSheet();
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                // ==========================================
                // SECTION: DATA
                // ==========================================
                _buildSectionTitle(AppLocalizations.of(context)!.data),
                _buildGroupCard([
                  SettingItem(
                    icon: Icons.ios_share,
                    title: AppLocalizations.of(context)!.exportJournals,
                    onTap: _exportJournals,
                  ),
                ]),
                const SizedBox(height: 32),

                // ==========================================
                // SECTION: DANGER ZONE
                // ==========================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dangerZone.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.systemRed,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildGroupCard([
                  SettingItem(
                    icon: Icons.restore_outlined,
                    title: AppLocalizations.of(context)!.resetSettings,
                    onTap: _confirmResetSettings,
                    isDestructive: true,
                  ),
                  SettingItem(
                    icon: Icons.delete_outline,
                    title: AppLocalizations.of(context)!.deleteAllJournals,
                    onTap: _confirmDeleteAll,
                    isDestructive: true,
                  ),
                ]),

                // ==========================================
                // FOOTER
                // ==========================================
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.madeWith,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================
            // FLOATING HEADER
            // ==========================================
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
                          AppLocalizations.of(context)!.settings,
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

  // ==========================================
  // HELPER: SECTION TITLE
  // ==========================================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SectionTitle(title: title),
    );
  }

  // ==========================================
  // HELPER: GROUP CARD
  // ==========================================
  Widget _buildGroupCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SettingsGroupCard(children: children),
    );
  }

  // ==========================================
  // TOMBOL BULAT
  // ==========================================
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

  // ==========================================
  // LANGUAGE SELECTOR (COMPACT)
  // ==========================================
  Widget _buildLanguageSelector() {
    final settingsBox = Hive.box('settingsBox');
    final currentLang = settingsBox.get('languageCode', defaultValue: 'system');

    return GestureDetector(
      key: _languageItemKey,
      onTap: () => _showLanguageMenu(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ikon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.language_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Label + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.language,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLanguageLabel(context, currentLang),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron (dengan animasi rotasi)
            AnimatedRotation(
              turns: _isLanguageMenuOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 27,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageLabel(BuildContext context, String langCode) {
    switch (langCode) {
      case 'system':
        return AppLocalizations.of(context)!.languageSystem;
      case 'en':
        return 'English';
      case 'id':
        return 'Indonesia';
      default:
        return 'System';
    }
  }

  // ==========================================
  // REMINDER TOGGLE
  // ==========================================
  Widget _buildReminderToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.dailyReminder,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _reminderEnabled,
            onChanged: (value) async {
              HapticService.selectionClick();
              await _toggleReminder(value);
            },
            activeThumbColor: AppColors.systemBlue,
            activeTrackColor: AppColors.systemBlue.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REMINDER: TIME
  // ==========================================
  Widget _buildReminderTime() {
    return GestureDetector(
      onTap: () async {
        HapticService.selectionClick();
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: AppColors.cardDark,
                  hourMinuteColor: AppColors.textPrimary.withValues(alpha: 0.1),
                  hourMinuteTextColor: AppColors.textPrimary,
                  dialBackgroundColor: AppColors.bgDark,
                  dialHandColor: AppColors.textPrimary,
                  dialTextColor: AppColors.textSecondary,
                  entryModeIconColor: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _reminderTime = picked;
          });

          final settingsBox = Hive.box('settingsBox');
          await settingsBox.put('reminderHour', picked.hour);
          await settingsBox.put('reminderMinute', picked.minute);

          if (_reminderEnabled) {
            await NotificationService().scheduleDailyReminder(
              hour: picked.hour,
              minute: picked.minute,
              message: _reminderMessageController.text.isEmpty
                  ? 'Waktunya menulis jurnal hari ini!'
                  : _reminderMessageController.text,
            );
          }
        }
      },
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
              child: Icon(
                Icons.access_time,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.reminderTime,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.systemBlue,
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

  // ==========================================
  // REMINDER: MESSAGE
  // ==========================================
  Widget _buildReminderMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.message_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context)!.reminderMessage,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reminderMessageController,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.reminderMessageHint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.bgDark,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) async {
              final settingsBox = Hive.box('settingsBox');
              await settingsBox.put('reminderMessage', value);

              if (_reminderEnabled) {
                await NotificationService().scheduleDailyReminder(
                  hour: _reminderTime.hour,
                  minute: _reminderTime.minute,
                  message: value.isEmpty
                      ? 'Waktunya menulis jurnal hari ini!'
                      : value,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REMINDER: TEST NOTIFICATION
  // ==========================================
  Widget _buildTestNotification() {
    return GestureDetector(
      onTap: () async {
        HapticService.mediumImpact();
        await NotificationService().showTestNotification(
          _reminderMessageController.text.isEmpty
              ? 'Waktunya menulis jurnal hari ini!'
              : _reminderMessageController.text,
        );
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.notificationSent);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.systemBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.send_outlined,
                color: AppColors.systemBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.testNotification,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.systemBlue,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.systemBlue,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageMenu(BuildContext context) async {
    HapticService.selectionClick();

    final settingsBox = Hive.box('settingsBox');
    final currentLang = settingsBox.get('languageCode', defaultValue: 'system');

    // Dapatkan posisi item Bahasa via GlobalKey
    final RenderBox? button =
        _languageItemKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    // Set state: popover terbuka
    setState(() => _isLanguageMenuOpen = true);

    final result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Language Menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Posisi popover: di bawah item Bahasa, rata kanan dengan chevron
            Positioned(
              top: buttonPosition.dy + button.size.height + 4,
              right:
                  overlay.size.width -
                  buttonPosition.dx -
                  button.size.width +
                  8,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageMenuItem(
                        'system',
                        AppLocalizations.of(context)!.languageSystem,
                        currentLang,
                      ),
                      Divider(
                        color: AppColors.dividerLight,
                        height: 1,
                        thickness: 1,
                      ),
                      _buildLanguageMenuItem('en', 'English', currentLang),
                      Divider(
                        color: AppColors.dividerLight,
                        height: 1,
                        thickness: 1,
                      ),
                      _buildLanguageMenuItem('id', 'Indonesia', currentLang),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (mounted) {
      setState(() => _isLanguageMenuOpen = false);
    }

    if (result != null && result != currentLang) {
      await settingsBox.put('languageCode', result);
      if (!mounted) return;
      HapticService.mediumImpact();
    }
  }

  Widget _buildLanguageMenuItem(
    String value,
    String label,
    String currentLang,
  ) {
    final isSelected = value == currentLang;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: AppColors.textPrimary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: AppColors.systemBlue, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // EXPORT JOURNALS
  // ==========================================
  Future<void> _exportJournals() async {
    final exportService = ExportService();

    if (!exportService.hasData()) {
      _showSnackBar(AppLocalizations.of(context)!.nothingToExport);
      return;
    }

    final filePath = await exportService.saveToTempFile();
    if (filePath == null) {
      if (!mounted) return;
      _showSnackBar('Gagal export jurnal.');
      return;
    }

    if (!mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'text/plain')],
        subject: 'NoteNest Export',
        text: 'Berikut adalah export jurnal dari NoteNest.',
      ),
    );
  }

  // ==========================================
  // DELETE ALL JOURNALS
  // ==========================================
  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deleteAllTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAllDesc,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final box = Hive.box<JournalEntry>('journalBox');
              await box.clear();
              if (!context.mounted) return;
              Navigator.pop(context);
              HapticService.heavyImpact();
              _showSnackBar(AppLocalizations.of(context)!.allJournalsDeleted);
            },
            child: Text(
              AppLocalizations.of(context)!.deleteAll,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RESET SETTINGS
  // ==========================================
  void _confirmResetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.resetSettingsTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.resetSettingsConfirm,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final settingsBox = Hive.box('settingsBox');

              await settingsBox.put('languageCode', 'en');
              await settingsBox.put('reminderEnabled', false);
              await settingsBox.put('reminderHour', 20);
              await settingsBox.put('reminderMinute', 0);
              await settingsBox.put(
                'reminderMessage',
                'Waktunya menulis jurnal hari ini!',
              );

              await NotificationService().cancelDailyReminder();

              if (!context.mounted) return;
              Navigator.pop(context);
              HapticService.heavyImpact();
              _showSnackBar(AppLocalizations.of(context)!.settingsReset);
            },
            child: Text(
              AppLocalizations.of(context)!.reset,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOGGLE REMINDER
  // ==========================================
  Future<void> _toggleReminder(bool value) async {
    if (value) {
      // Cek + minta izin (dengan dialog kalau permanently denied)
      final granted = await checkPermissionWithDialog(
        context,
        Permission.notification,
      );

      if (!granted) {
        // Izin tidak diberikan → toggle tetap OFF
        return;
      }
    }

    // Izin granted (atau user mau matikan) → update state
    setState(() {
      _reminderEnabled = value;
    });

    final settingsBox = Hive.box('settingsBox');
    await settingsBox.put('reminderEnabled', value);

    final service = NotificationService();
    if (value) {
      await service.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        message: _reminderMessageController.text.isEmpty
            ? 'Waktunya menulis jurnal hari ini!'
            : _reminderMessageController.text,
      );
    } else {
      await service.cancelDailyReminder();
    }

    if (!mounted) return;
    _showSnackBar(AppLocalizations.of(context)!.reminderSaved);
  }

  // ==========================================
  // FEEDBACK BOTTOM SHEET
  // ==========================================
  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FeedbackBottomSheet(
          controller: _feedbackController,
          onSendEmail: _sendFeedbackViaEmailWithText,
          onSendWhatsApp: _sendFeedbackViaWhatsApp,
        );
      },
    );
  }

  Future<void> _sendFeedbackViaWhatsApp(String feedbackText) async {
    const String phoneNumber = '6285123644293';

    final String message = feedbackText.isEmpty
        ? 'Halo Feri, saya ingin memberi feedback tentang NoteNest:\n\n'
        : feedbackText;

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('WhatsApp tidak terinstall');
    }
  }

  Widget _buildHapticToggle() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settingsBox').listenable(),
      builder: (context, box, _) {
        final hapticEnabled = box.get('hapticEnabled', defaultValue: true);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vibration,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.hapticFeedback,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              Switch(
                value: hapticEnabled,
                onChanged: (value) async {
                  await box.put('hapticEnabled', value);
                  // Kasih getar 1x saat baru dinyalakan (pakai HapticService langsung biar tetap getar meski baru dinyalakan)
                  if (value) {
                    HapticFeedback.lightImpact();
                  }
                },
                activeThumbColor: AppColors.systemBlue,
                activeTrackColor: AppColors.systemBlue.withValues(alpha: 0.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendFeedbackViaEmailWithText(String feedbackText) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ferdiantoferi1303@gmail.com',
      query: Uri.encodeFull('subject=NoteNest Feedback&body=$feedbackText'),
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Tidak ada aplikasi email terinstall');
    }
  }

  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }
}

// ==========================================
// WIDGET: FEEDBACK BOTTOM SHEET
// ==========================================
class _FeedbackBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function(String) onSendEmail;
  final Future<void> Function(String) onSendWhatsApp;

  const _FeedbackBottomSheet({
    required this.controller,
    required this.onSendEmail,
    required this.onSendWhatsApp,
  });

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
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
                AppLocalizations.of(context)!.sendFeedback,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.feedbackWhatHappened,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.controller,
                maxLines: null,
                maxLength: 2000,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.feedbackHint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.bgDark,
                  counterStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.feedbackDisclaimer,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // === EXPANDABLE: "LIHAT OPSI LAIN" ===
              GestureDetector(
                onTap: () {
                  HapticService.selectionClick();
                  // SEKARANG SETSTATE-NYA ADA DI DALAM BOTTOM SHEET!
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lihat opsi lain',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === KONTEN EXPAND ===
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              HapticService.selectionClick();
                              Navigator.pop(context);
                              widget.onSendWhatsApp(widget.controller.text);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFF25D366,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF25D366,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Color(0xFF25D366),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: widget.controller,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;
                  return GestureDetector(
                    onTap: hasText
                        ? () {
                            HapticService.mediumImpact();
                            Navigator.pop(context);
                            widget.onSendEmail(value.text);
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: hasText
                            ? AppColors.systemBlue
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.send,
                          style: TextStyle(
                            color: hasText
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
