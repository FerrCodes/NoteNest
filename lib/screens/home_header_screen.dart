import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_group_card.dart';
import '../utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/haptic_service.dart';
import '../widgets/custom_floating_header.dart';

class HomeHeaderScreen extends StatefulWidget {
  const HomeHeaderScreen({super.key});

  @override
  State<HomeHeaderScreen> createState() => _HomeHeaderScreenState();
}

class _HomeHeaderScreenState extends State<HomeHeaderScreen> {
  bool _showDate = true;
  bool _showTime = true;
  bool _showWeather = false;
  final _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsBox = Hive.box('settingsBox');
    setState(() {
      _showDate = settingsBox.get('showDate', defaultValue: true);
      _showTime = settingsBox.get('showTime', defaultValue: true);
      _showWeather = settingsBox.get('showWeather', defaultValue: false);
      _userNameController.text = settingsBox.get(
        'userName',
        defaultValue: 'Feri',
      );
    });
  }

  @override
  void dispose() {
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
            // ==========================================
            // KONTEN UTAMA
            // ==========================================
            ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                bottom: 24,
              ),
              children: [
                // === DESKRIPSI ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context)!.headerScreenDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // === SECTION: NAMA KAMU ===
                _buildSectionTitle(AppLocalizations.of(context)!.userName),
                _buildGroupCard([_buildUserNameField()]),
                const SizedBox(height: 32),

                // === SECTION: TAMPILKAN ===
                _buildSectionTitle(
                  AppLocalizations.of(context)!.displaySection,
                ),
                _buildGroupCard([
                  _buildHeaderToggle(
                    icon: Icons.calendar_today_outlined,
                    title: AppLocalizations.of(context)!.showDate,
                    subtitle: AppLocalizations.of(context)!.showDateDesc,
                    value: _showDate,
                    onChanged: (value) async {
                      HapticService.selectionClick();
                      final settingsBox = Hive.box('settingsBox');
                      await settingsBox.put('showDate', value);
                      setState(() => _showDate = value);
                    },
                  ),
                  _buildHeaderToggle(
                    icon: Icons.access_time,
                    title: AppLocalizations.of(context)!.showTime,
                    subtitle: AppLocalizations.of(context)!.showTimeDesc,
                    value: _showTime,
                    onChanged: (value) async {
                      HapticService.selectionClick();
                      final settingsBox = Hive.box('settingsBox');
                      await settingsBox.put('showTime', value);
                      if (!mounted) return;
                      setState(() => _showTime = value);
                    },
                  ),
                  _buildHeaderToggle(
                    icon: Icons.wb_sunny_outlined,
                    title: AppLocalizations.of(context)!.showWeather,
                    subtitle: AppLocalizations.of(context)!.showWeatherDesc,
                    value: _showWeather,
                    showBetaBadge: true,
                    onChanged: (value) async {
                      HapticService.selectionClick();
                      final settingsBox = Hive.box('settingsBox');

                      if (value) {
                        // 1. Tampilkan dialog peringatan BETA dulu
                        final proceed = await _showBetaDialog();
                        if (!proceed) return;

                        if (!context.mounted) return;

                        // 2. Jika setuju, BARU minta izin lokasi
                        // Cek + minta izin lokasi
                        final granted = await checkPermissionWithDialog(
                          context,
                          Permission.locationWhenInUse,
                        );
                        if (!granted) return;

                        // 3. Jika user menolak izin, kembalikan switch ke OFF
                        if (!granted) {
                          if (!mounted) return;
                          // Opsional: Tampilkan SnackBar bahwa izin dibutuhkan
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Izin lokasi dibutuhkan untuk fitur cuaca',
                              ),
                            ),
                          );
                          return;
                        }

                        if (!mounted) return;

                        // 4. Izin diberikan -> Simpan ke database
                        await settingsBox.put('showWeather', true);
                        if (!mounted) return;
                        setState(() => _showWeather = true);
                      } else {
                        // Jika dimatikan, matikan tanpa perlu tanya izin
                        await settingsBox.put('showWeather', false);
                        if (!mounted) return;
                        setState(() => _showWeather = false);
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),

            // ==========================================
            // FLOATING HEADER (Back + Pill Judul + Spacer)
            // ==========================================
            CustomFloatingHeader(
              onBack: () => Navigator.pop(context),
              title: HeaderTitlePill(
                child: Text(
                  AppLocalizations.of(context)!.headerSection,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // rightWidget tidak perlu diisi karena memang tidak ada tombol kanan.
              // CustomFloatingHeader akan otomatis menambahkan spacer di kanan.
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
  // WIDGET: HEADER TOGGLE
  // ==========================================
  Widget _buildHeaderToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBetaBadge = false,
  }) {
    return Padding(
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
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 16),

          // Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Badge BETA
                    if (showBetaBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.systemYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BETA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.systemYellow,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
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

          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.systemBlue,
            activeTrackColor: AppColors.systemBlue.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Future<bool> _showBetaDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.betaFeatureTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.betaFeatureDesc,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.continueAction,
              style: TextStyle(
                color: AppColors.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ==========================================
  // WIDGET: USER NAME FIELD
  // ==========================================
  Widget _buildUserNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _userNameController,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
              maxLength: 20,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.userNameHint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 15,
                ),
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) async {
                final settingsBox = Hive.box('settingsBox');
                await settingsBox.put('userName', value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
