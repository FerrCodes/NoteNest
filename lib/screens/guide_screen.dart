import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/custom_floating_header.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
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
                    AppLocalizations.of(context)!.guideDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // === SECTION: FITUR TERSEMBUNYI ===
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SectionTitle(
                    title: AppLocalizations.of(context)!.guideHiddenFeatures,
                  ),
                ),
                _buildGroupCard([
                  _buildGuideItem(
                    icon: Icons.tune,
                    title: AppLocalizations.of(context)!.guideDropdownTitle,
                    desc: AppLocalizations.of(context)!.guideDropdownDesc,
                  ),
                  _buildGuideItem(
                    icon: Icons.swipe,
                    title: AppLocalizations.of(context)!.guideCarouselTitle,
                    desc: AppLocalizations.of(context)!.guideCarouselDesc,
                  ),
                ]),

                // === FOOTER ===
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.guideFooter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================
            // FLOATING HEADER
            // ==========================================
            CustomFloatingHeader(
              onBack: () => Navigator.pop(context),
              title: HeaderTitlePill(
                child: Text(
                  AppLocalizations.of(context)!.guideTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
  // ITEM GUIDE
  // ==========================================
  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Title + Desc
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
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
