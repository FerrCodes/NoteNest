import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/top_banner.dart';
import '../services/export_service.dart';
import '../widgets/section_title.dart';
import '../widgets/setting_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);
  bool _isSocialMediaExpanded = false;
  // State Reminder
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final TextEditingController _reminderMessageController =
      TextEditingController();
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
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.resetSettingsTitle,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.resetSettingsConfirm,
          style: TextStyle(color: textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: textSecondary),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // === KONTEN UTAMA ===
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              children: [
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
                // === SECTION BAHASA ===
                SectionTitle(title: AppLocalizations.of(context)!.language),
                const SizedBox(height: 12),
                _buildLanguageSelector(),
                const SizedBox(height: 32),

                // === SECTION DATA ===
                SectionTitle(title: AppLocalizations.of(context)!.data),
                const SizedBox(height: 12),
                SettingItem(
                  icon: Icons.ios_share,
                  title: AppLocalizations.of(context)!.exportJournals,
                  subtitle: AppLocalizations.of(context)!.exportJournalsDesc,
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
                  onTap: _showAboutDialog,
                ),
                const SizedBox(height: 8),
                SettingItem(
                  icon: Icons.mail_outline,
                  title: AppLocalizations.of(context)!.sendFeedback,
                  subtitle: AppLocalizations.of(context)!.feedbackDesc,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    _showFeedbackOptionsDialog(context);
                  },
                ),
                const SizedBox(height: 8),
                // === SOURCE CODE (dengan ikon GitHub asli) ===
                SettingItem(
                  customIcon: const FaIcon(
                    FontAwesomeIcons.github,
                    color: Color(0xFFF2F2F7),
                    size: 20,
                  ),
                  title: AppLocalizations.of(context)!.sourceCode,
                  subtitle: AppLocalizations.of(context)!.sourceCodeDesc,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final Uri repoUri = Uri.parse(
                      'https://github.com/FerrCodes/Note-Nest',
                    );
                    try {
                      await launchUrl(
                        repoUri,
                        mode: LaunchMode.platformDefault,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      _showSnackBar('Gagal membuka GitHub: $e');
                    }
                  },
                ),
                const SizedBox(height: 40),

                // === DANGER ZONE ===
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
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
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    AppLocalizations.of(context)!.dangerZoneDesc,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ),
                const SizedBox(height: 12),

                // Reset Settings
                SettingItem(
                  icon: Icons.restore_outlined,
                  title: AppLocalizations.of(context)!.resetSettings,
                  subtitle: AppLocalizations.of(context)!.resetSettingsDesc,
                  onTap: _confirmResetSettings,
                  isDestructive: true,
                ),
                const SizedBox(height: 8),

                // Delete All Journals
                SettingItem(
                  icon: Icons.delete_outline,
                  title: AppLocalizations.of(context)!.deleteAllJournals,
                  subtitle: AppLocalizations.of(context)!.deleteAllJournalsDesc,
                  onTap: _confirmDeleteAll,
                  isDestructive: true,
                ),

                // === FOOTER ===
                const SizedBox(height: 8),
                const SizedBox(height: 40),

                // === FOOTER ===
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.madeWith,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary.withValues(alpha: 0.5),
                      height: 1.6,
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
                icon: Icons.close,
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
                    color: cardColor.withValues(alpha: 0.9),
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
                      color: textPrimary,
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
          color: cardColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: textPrimary, size: 20),
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
            color: cardColor,
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
            style: TextStyle(fontSize: 12, color: textSecondary, height: 1.5),
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
          color: isSelected ? textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? bgColor : textPrimary,
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
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deleteAllTitle,
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAllDesc,
          style: TextStyle(color: textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: textSecondary),
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

  // === FUNGSI TENTANG ===
  void _showAboutDialog() {
    // Reset dropdown ke tertutup setiap kali modal dibuka
    _isSocialMediaExpanded = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === LOGO & NAMA ===
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: textPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          color: textPrimary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.appName,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.version,
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === DESKRIPSI APLIKASI ===
                Text(
                  AppLocalizations.of(context)!.appDescription,
                  style: TextStyle(
                    color: textSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // === DEVELOPER ===
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0A84FF,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.manage_accounts_outlined,
                          color: Color(0xFF0A84FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.aboutDeveloper,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.aboutDeveloperName,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // === DROPDOWN MEDIA SOSIAL ===
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setModalState(() {
                      _isSocialMediaExpanded = !_isSocialMediaExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: textPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.public_outlined,
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.socialMedia,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.socialMediaDesc,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isSocialMediaExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: textSecondary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),

                        // === KONTEN DROPDOWN ===
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            children: [
                              const SizedBox(height: 12),
                              const Divider(
                                color: Color(0xFF2C2C2E),
                                height: 1,
                              ),
                              const SizedBox(height: 12),

                              // Instagram
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.selectionClick();
                                  final Uri uri = Uri.parse(
                                    'https://www.instagram.com/imnotferrriii/',
                                  );
                                  try {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.platformDefault,
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    _showSnackBar(
                                      'Gagal membuka Instagram: $e',
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              colors: [
                                                Color(0xFF833AB4),
                                                Color(0xFFFD1D1D),
                                                Color(0xFFFCB045),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(bounds),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.aboutInstagramHandle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: textSecondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // GitHub
                              GestureDetector(
                                onTap: () async {
                                  HapticFeedback.selectionClick();
                                  final Uri uri = Uri.parse(
                                    'https://github.com/FerrCodes',
                                  );
                                  try {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.platformDefault,
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    _showSnackBar('Gagal membuka GitHub: $e');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              colors: [
                                                Color(0xFF6E7681),
                                                Color(0xFFC9D1D9),
                                                Color(0xFFF0F6FC),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(bounds),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.aboutGithubHandle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: textSecondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          crossFadeState: _isSocialMediaExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Color(0xFF0A84FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === REMINDER: TOGGLE ===
  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: textPrimary,
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
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.dailyReminderDesc,
                  style: TextStyle(fontSize: 12, color: textSecondary),
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
                  backgroundColor: cardColor,
                  hourMinuteColor: textPrimary.withValues(alpha: 0.1),
                  hourMinuteTextColor: textPrimary,
                  dialBackgroundColor: bgColor,
                  dialHandColor: textPrimary,
                  dialTextColor: textSecondary,
                  entryModeIconColor: textPrimary,
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
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.access_time, color: textPrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.reminderTime,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
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
              color: textSecondary.withValues(alpha: 0.5),
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
        color: cardColor,
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
                  color: textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.message_outlined,
                  color: textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context)!.reminderMessage,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reminderMessageController,
            style: TextStyle(color: textPrimary, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.reminderMessageHint,
              hintStyle: TextStyle(
                color: textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              filled: true,
              fillColor: bgColor,
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
          color: cardColor,
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
                    style: TextStyle(fontSize: 12, color: textSecondary),
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

  // === DIALOG PILIHAN FEEDBACK ===
  void _showFeedbackOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.sendFeedback,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sendFeedbackOptions,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Tombol Email
            // Tombol Email (dengan ikon Gmail asli)
            _buildFeedbackOption(
              customIcon: const FaIcon(
                FontAwesomeIcons.envelope,
                color: Color(0xFFEA4335), // Warna merah Gmail
                size: 20,
              ),
              label: AppLocalizations.of(context)!.viaEmail,
              color: const Color(0xFFEA4335),
              onTap: () {
                Navigator.pop(context);
                _sendFeedbackViaEmail();
              },
            ),
            const SizedBox(height: 10),
            // Tombol WhatsApp (dengan ikon WhatsApp asli)
            _buildFeedbackOption(
              customIcon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366), // Warna hijau WhatsApp
                size: 20,
              ),
              label: AppLocalizations.of(context)!.viaWhatsApp,
              color: const Color(0xFF25D366),
              onTap: () {
                Navigator.pop(context);
                _sendFeedbackViaWhatsApp();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET TOMBOL PILIHAN FEEDBACK ===
  Widget _buildFeedbackOption({
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: customIcon ?? Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // === KIRIM FEEDBACK VIA EMAIL ===
  Future<void> _sendFeedbackViaEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ferdiantoferi1303@gmail.com',
      query: Uri.encodeFull(
        'subject=NoteNest Feedback&body=${AppLocalizations.of(context)!.feedbackMessage}',
      ),
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Tidak ada aplikasi email terinstall');
    }
  }

  // === KIRIM FEEDBACK VIA WHATSAPP ===
  Future<void> _sendFeedbackViaWhatsApp() async {
    const String phoneNumber = '6285123644293';

    final String message = AppLocalizations.of(context)!.feedbackMessage;
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.noWhatsApp);
    }
  }

  // === SNACKBAR HELPER ===
  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }
}
