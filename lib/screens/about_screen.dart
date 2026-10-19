import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/app_tooltip.dart';
import '../services/haptic_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
                bottom: 25,
              ),
              children: [
                // === HEADER: LOGO, NAMA, VERSI ===
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.appName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DMSerifDisplay',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.version,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === DESKRIPSI APLIKASI ===
                _buildGroupCard([
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context)!.appDescription,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),

                // === SECTION: SOSIAL MEDIA ===
                _buildSectionTitle(AppLocalizations.of(context)!.socialMedia),
                _buildGroupCard([
                  _buildSocialItem(
                    label: AppLocalizations.of(context)!.aboutInstagramHandle,
                    icon: const FaIcon(
                      FontAwesomeIcons.instagram,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    gradientColors: const [
                      Color(0xFF833AB4),
                      Color(0xFFFD1D1D),
                      Color(0xFFFCB045),
                    ],
                    onTap: () =>
                        _launchUrl('https://www.instagram.com/imnotferrriii/'),
                  ),
                  _buildSocialItem(
                    label: AppLocalizations.of(context)!.aboutGithubHandle,
                    icon: const FaIcon(
                      FontAwesomeIcons.github,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    gradientColors: const [
                      Color(0xFF6E7681),
                      Color(0xFFC9D1D9),
                      Color(0xFFF0F6FC),
                    ],
                    onTap: () => _launchUrl('https://github.com/FerrCodes'),
                  ),
                  _buildSocialItem(
                    label: AppLocalizations.of(context)!.privacyPolicy,
                    icon: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    gradientColors: const [
                      Color.fromARGB(255, 148, 190, 248),
                      Color.fromARGB(255, 148, 190, 248),
                      Color(0xFFF0F6FC),
                    ],
                    // GANTI URL DI BAWAH DENGAN LINK GOOGLE DOCS-MU
                    onTap: () => _launchUrl(
                      'https://docs.google.com/document/d/1d673w4V73Iu48MYh7QFRYJvkbkB-n0jIDuE5c5I7TlM/edit?usp=sharing',
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context)!.socialMediaDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
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

            // ==========================================
            // FLOATING HEADER (Back + Pill Judul + GitHub)
            // ==========================================
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol Back
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),

                  // Pill Judul
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
                          AppLocalizations.of(context)!.aboutApp,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol GitHub
                  AppTooltip(
                    message: AppLocalizations.of(context)!.sourceCode,
                    child: GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        _launchUrl('https://github.com/FerrCodes/Note-Nest');
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
                        child: const FaIcon(
                          FontAwesomeIcons.github,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER: SECTION TITLE (di luar card)
  // ==========================================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SectionTitle(title: title),
    );
  }

  // ==========================================
  // HELPER: GROUP CARD (gaya ChatGPT)
  // ==========================================
  Widget _buildGroupCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SettingsGroupCard(children: children),
    );
  }

  // ==========================================
  // WIDGET: SOCIAL MEDIA ITEM (di dalam group card)
  // ==========================================
  Widget _buildSocialItem({
    required String label,
    required Widget icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
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
  // HELPER: LAUNCH URL
  // ==========================================
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka link: $e'),
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 90, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
}
