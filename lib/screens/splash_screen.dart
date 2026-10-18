import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'onboarding_screen.dart';
import 'reflect_screen.dart';
import '../theme/app_colors.dart';
import 'name_input_screen.dart';
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
    await Future.delayed(const Duration(seconds: 2));

    final settingsBox = Hive.box('settingsBox');
    final hasSeenOnboarding = settingsBox.get(
      'hasSeenOnboarding',
      defaultValue: false,
    );
    final hasSetName = settingsBox.get('hasSetName', defaultValue: false);

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      // 1. Jika belum pernah lihat onboarding -> Ke Onboarding
      Navigator.pushReplacement(
        context,
        SlideRoute(page: const OnboardingScreen()),
      );
    } else if (!hasSetName) {
      // 2. Jika sudah lihat onboarding, tapi belum isi nama -> Ke Input Nama
      Navigator.pushReplacement(
        context,
        SlideRoute(page: const NameInputScreen()),
      );
    } else {
      // 3. Jika sudah lengkap semua -> Ke Beranda
      Navigator.pushReplacement(
        context,
        SlideRoute(page: const ReflectScreen()),
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
            Text(
              'Reflect. Write. Grow.',
              style: const TextStyle(
                fontSize: 25,
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
