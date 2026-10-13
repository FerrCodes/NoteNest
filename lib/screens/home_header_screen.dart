import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/top_banner.dart';

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

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
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
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              children: [
                // === DESKRIPSI ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                SectionTitle(title: AppLocalizations.of(context)!.userName),
                const SizedBox(height: 12),
                _buildUserNameField(),
                const SizedBox(height: 32),

                // === SECTION: TAMPILKAN ===
                SectionTitle(
                  title: AppLocalizations.of(context)!.displaySection,
                ),
                const SizedBox(height: 12),
                _buildHeaderToggle(
                  icon: Icons.calendar_today_outlined,
                  title: AppLocalizations.of(context)!.showDate,
                  subtitle: AppLocalizations.of(context)!.showDateDesc,
                  value: _showDate,
                  onChanged: (value) async {
                    HapticFeedback.selectionClick();
                    final settingsBox = Hive.box('settingsBox');
                    await settingsBox.put('showDate', value);
                    setState(() => _showDate = value);
                  },
                ),
                const SizedBox(height: 8),
                _buildHeaderToggle(
                  icon: Icons.access_time,
                  title: AppLocalizations.of(context)!.showTime,
                  subtitle: AppLocalizations.of(context)!.showTimeDesc,
                  value: _showTime,
                  onChanged: (value) async {
                    HapticFeedback.selectionClick();
                    final settingsBox = Hive.box('settingsBox');
                    await settingsBox.put('showTime', value);
                    setState(() => _showTime = value);
                  },
                ),
                const SizedBox(height: 8),
                _buildHeaderToggle(
                  icon: Icons.wb_sunny_outlined,
                  title: AppLocalizations.of(context)!.showWeather,
                  subtitle: AppLocalizations.of(context)!.showWeatherDesc,
                  value: _showWeather,
                  onChanged: (value) async {
                    HapticFeedback.selectionClick();

                    // Ambil localization SEBELUM await
                    final l10n = AppLocalizations.of(context)!;

                    final settingsBox = Hive.box('settingsBox');
                    await settingsBox.put('showWeather', value);
                    setState(() => _showWeather = value);

                    if (value) {
                      final granted = await _checkLocationPermission();
                      if (!granted && mounted) {
                        await settingsBox.put('showWeather', false);
                        if (!mounted) return;
                        setState(() => _showWeather = false);
                        _showSnackBar(
                          l10n.permissionDenied,
                          type: BannerType.error,
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),

            // === TOMBOL BACK (KIRI ATAS) ===
            Positioned(
              top: 12,
              left: 20,
              child: _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // === PILL JUDUL ===
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
                    AppLocalizations.of(context)!.headerSection,
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

  Widget _buildHeaderToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
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

  Widget _buildUserNameField() {
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
                counterText: '', // sembunyikan counter
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
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  void _showSnackBar(String message, {BannerType type = BannerType.success}) {
    TopBanner.show(context, message: message, type: type);
  }
}
