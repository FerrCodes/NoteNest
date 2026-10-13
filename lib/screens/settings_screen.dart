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
import '../theme/app_colors.dart';
import 'about_screen.dart';
import '../utils/slide_route.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State Header Beranda
  final _userNameController = TextEditingController(); // State Reminder
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final TextEditingController _reminderMessageController =
      TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  // === FUNGSI RESET SETTINGS ===
  void _confirmResetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.resetSettingsTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
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

              // Reset semua pengaturan
              await settingsBox.put('languageCode', 'en');
              await settingsBox.put('reminderEnabled', false);
              await settingsBox.put('reminderHour', 20);
              await settingsBox.put('reminderMinute', 0);
              await settingsBox.put(
                'reminderMessage',
                'Waktunya menulis jurnal hari ini!',
              );

              // Batalkan notifikasi
              await NotificationService().cancelDailyReminder();

              if (!context.mounted) return;
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
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
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA ===
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 25),
              children: [
                // === SECTION BAHASA ===
                SectionTitle(title: AppLocalizations.of(context)!.language),
                const SizedBox(height: 12),
                _buildLanguageSelector(),
                const SizedBox(height: 32),
                // === SECTION REMINDER ===
                SectionTitle(title: AppLocalizations.of(context)!.reminder),
                const SizedBox(height: 12),
                _buildReminderToggle(),
                if (_reminderEnabled) ...[
                  const SizedBox(height: 8),
                  _buildReminderTime(),
                  const SizedBox(height: 8),
                  _buildReminderMessage(),
                  const SizedBox(height: 8),
                  _buildTestNotification(),
                ],
                const SizedBox(height: 32),
                // === SECTION DATA ===
                SectionTitle(title: AppLocalizations.of(context)!.data),
                const SizedBox(height: 12),
                SettingItem(
                  icon: Icons.ios_share,
                  title: AppLocalizations.of(context)!.exportJournals,
                  onTap: _exportJournals,
                ),
                const SizedBox(height: 32),
                // === SECTION 2: TENTANG ===
                SectionTitle(title: AppLocalizations.of(context)!.about),
                const SizedBox(height: 12),
                SettingItem(
                  icon: Icons.info_outline,
                  title: AppLocalizations.of(context)!.aboutApp,
                  subtitle: AppLocalizations.of(context)!.version,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      SlideRoute(page: const AboutScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SettingItem(
                  icon: Icons.mail_outline,
                  title: AppLocalizations.of(context)!.sendFeedback,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    _showFeedbackBottomSheet();
                  },
                ),
                const SizedBox(height: 40),

                // === DANGER ZONE ===
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dangerZone.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reset Settings
                SettingItem(
                  icon: Icons.restore_outlined,
                  title: AppLocalizations.of(context)!.resetSettings,
                  onTap: _confirmResetSettings,
                  isDestructive: true,
                ),
                const SizedBox(height: 8),

                // Delete All Journals
                SettingItem(
                  icon: Icons.delete_outline,
                  title: AppLocalizations.of(context)!.deleteAllJournals,
                  onTap: _confirmDeleteAll,
                  isDestructive: true,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    AppLocalizations.of(context)!.dangerZoneDesc,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // === FOOTER ===
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.madeWith,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            // === TOMBOL CLOSE (KIRI ATAS) ===
            Positioned(
              top: 12,
              left: 20,
              child: _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // === PILL JUDUL (TENGAH ATAS) ===
            Positioned(
              top: 12,
              left: 0,
              right: 0,
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
          ],
        ),
      ),
    );
  }

  // === TOMBOL BULAT ===
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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

  // === LANGUAGE SELECTOR ===
  Widget _buildLanguageSelector() {
    final settingsBox = Hive.box('settingsBox');
    final currentLang = settingsBox.get('languageCode', defaultValue: 'en');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle bahasa
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: _buildLangOption('en', 'English', currentLang)),
              const SizedBox(width: 8),
              Expanded(child: _buildLangOption('id', 'Indonesia', currentLang)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Deskripsi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocalizations.of(context)!.languageDesc,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLangOption(String code, String label, String currentLang) {
    final isSelected = currentLang == code;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final settingsBox = Hive.box('settingsBox');
        await settingsBox.put('languageCode', code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.bgDark : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // === FUNGSI EXPORT ===
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

  // === FUNGSI HAPUS SEMUA ===
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
              HapticFeedback.heavyImpact();
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

  // === REMINDER: TOGGLE ===
  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.dailyReminder,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.dailyReminderDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _reminderEnabled,
            onChanged: (value) async {
              HapticFeedback.selectionClick();
              await _toggleReminder(value);
            },
            activeThumbColor: const Color(0xFF0A84FF),
            activeTrackColor: const Color(0xFF0A84FF).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  // === REMINDER: LOGIKA TOGGLE ===
  Future<void> _toggleReminder(bool value) async {
    final service = NotificationService();

    if (value) {
      // Minta izin
      final granted = await service.requestPermission();
      if (!granted) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.permissionDenied);
        return;
      }
    }

    setState(() {
      _reminderEnabled = value;
    });

    final settingsBox = Hive.box('settingsBox');
    await settingsBox.put('reminderEnabled', value);

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

  // === REMINDER: TIME PICKER ===
  Widget _buildReminderTime() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
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

          // Re-schedule reminder
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
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
                color: const Color(0xFF0A84FF),
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

  // === REMINDER: MESSAGE INPUT ===
  Widget _buildReminderMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
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

              // Re-schedule reminder
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

  // === REMINDER: TEST NOTIFICATION ===
  Widget _buildTestNotification() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await NotificationService().showTestNotification(
          _reminderMessageController.text.isEmpty
              ? 'Waktunya menulis jurnal hari ini!'
              : _reminderMessageController.text,
        );
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.notificationSent);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_outlined,
                color: Color(0xFF0A84FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.testNotification,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A84FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.testNotificationDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF0A84FF),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                  // === DRAG HANDLE (Garis kecil di atas) ===
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

                  // === TITLE ===
                  Text(
                    AppLocalizations.of(context)!.sendFeedback,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // === SUBTITLE ===
                  Text(
                    AppLocalizations.of(context)!.feedbackWhatHappened,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // === TEXT FIELD ===
                  TextField(
                    controller: _feedbackController,
                    maxLines: null,
                    maxLength: 2000,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
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

                  // === DISCLAIMER ===
                  Text(
                    AppLocalizations.of(context)!.feedbackDisclaimer,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === TOMBOL SEND (Mengikuti status teks) ===
                  ValueListenableBuilder(
                    valueListenable: _feedbackController,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: hasText
                            ? () {
                                HapticFeedback.mediumImpact();
                                // Kirim via email (bisa juga WhatsApp)
                                _sendFeedbackViaEmailWithText(value.text);
                                Navigator.pop(context);
                              }
                            : null, // Tombol mati kalau kosong
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: hasText
                                ? AppColors.systemBlue
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.2,
                                  ),
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
      },
    );
  }

  // === KIRIM FEEDBACK VIA EMAIL ===
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

  // === SNACKBAR HELPER ===
  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }
}
