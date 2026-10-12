import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/app_tooltip.dart';

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
            // === KONTEN UTAMA ===
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 25),
              children: [
                // === HEADER: LOGO, NAMA, VERSI ===
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.05),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          color: AppColors.textPrimary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.appName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
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
                const SizedBox(height: 32),

                // === DESKRIPSI APLIKASI ===
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.appDescription,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // === SECTION: FITUR UTAMA ===
                SectionTitle(
                  title: AppLocalizations.of(context)!.aboutFeatures,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        Icons.edit_note,
                        AppLocalizations.of(context)!.aboutFeature1,
                      ),
                      _buildFeatureItem(
                        Icons.photo_camera_outlined,
                        AppLocalizations.of(context)!.aboutFeature2,
                      ),
                      _buildFeatureItem(
                        Icons.mood_outlined,
                        AppLocalizations.of(context)!.aboutFeature3,
                      ),
                      _buildFeatureItem(
                        Icons.bar_chart_outlined,
                        AppLocalizations.of(context)!.aboutFeature4,
                      ),
                      _buildFeatureItem(
                        Icons.language_outlined,
                        AppLocalizations.of(context)!.aboutFeature5,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // === SECTION: SOSIAL MEDIA ===
                SectionTitle(title: AppLocalizations.of(context)!.socialMedia),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Instagram
                      _buildSocialItem(
                        label: AppLocalizations.of(
                          context,
                        )!.aboutInstagramHandle,
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
                        onTap: () => _launchUrl(
                          'https://www.instagram.com/imnotferrriii/',
                        ),
                      ),
                      const Divider(color: Color(0xFF2C2C2E), height: 20),
                      // GitHub Profile
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
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // === DESKRIPSI ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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

            // === TOMBOL GITHUB (KANAN ATAS) ===
            Positioned(
              top: 12,
              right: 20,
              child: AppTooltip(
                message: AppLocalizations.of(context)!.sourceCode,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
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
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET: FITUR ITEM ===
  Widget _buildFeatureItem(IconData icon, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET: SOCIAL MEDIA ITEM (dengan gradient shader) ===
  Widget _buildSocialItem({
    required String label,
    required Widget icon, // <-- Ganti ke Widget
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            icon, // <-- Langsung pakai widget icon
            const SizedBox(width: 14),
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
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  // === HELPER: LAUNCH URL ===
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
