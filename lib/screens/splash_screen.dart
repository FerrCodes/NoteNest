import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'onboarding_screen.dart';
import 'reflect_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/slide_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // Tunggu 2 detik untuk efek splash
    await Future.delayed(const Duration(seconds: 2));

    final settingsBox = Hive.box('settingsBox');
    final hasSeenOnboarding = settingsBox.get(
      'hasSeenOnboarding',
      defaultValue: false,
    );

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        SlideRoute(page: const ReflectScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        SlideRoute(page: const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
              child: const Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'DMSerifDisplay',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reflect. Write. Grow.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
