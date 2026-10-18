import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/journal_entry.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'services/notification_service.dart';
import 'models/custom_mood.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Daftarkan adapter
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(CustomMoodAdapter());

  // Buka box
  await Hive.openBox<JournalEntry>('journalBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox<CustomMood>('customMoodsBox');

  // === SET DEFAULT HEADER SETTINGS ===
  final settingsBox = Hive.box('settingsBox');
  if (settingsBox.get('headerInitialized') != true) {
    await settingsBox.put('showDate', true);
    await settingsBox.put('showTime', true);
    await settingsBox.put('showWeather', false);
    await settingsBox.put('userName', '');
    await settingsBox.put('headerInitialized', true);
  }

  await NotificationService().initialize();
  // Set status bar untuk dark mode (ikon putih)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settingsBox');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, Box box, _) {
        final langSetting = box.get('languageCode', defaultValue: 'system');

        // Logika bahasa:
        // 'system'  → ikut bahasa HP (kalau tidak didukung, fallback ke 'en')
        // 'en'      → English
        // 'id'      → Indonesia
        Locale appLocale;
        if (langSetting == 'system') {
          final deviceLocale = PlatformDispatcher.instance.locale;
          final deviceLang = deviceLocale.languageCode;
          // Cek apakah HP support 'id' atau 'en', kalau tidak → 'en'
          if (deviceLang == 'id') {
            appLocale = const Locale('id');
          } else {
            appLocale = const Locale('en');
          }
        } else {
          appLocale = Locale(langSetting as String);
        }

        return MaterialApp(
          locale: appLocale,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.dark,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
