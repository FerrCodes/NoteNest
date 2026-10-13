import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WeatherHeader extends StatefulWidget {
  final bool showDate;
  final bool showTime;
  final bool showWeather;

  const WeatherHeader({
    super.key,
    required this.showDate,
    required this.showTime,
    required this.showWeather,
  });

  @override
  State<WeatherHeader> createState() => _WeatherHeaderState();
}

class _WeatherHeaderState extends State<WeatherHeader> {
  final _weatherService = WeatherService();
  WeatherData? _weather;

  @override
  void initState() {
    super.initState();
    if (widget.showWeather) {
      _loadWeather();
    }
  }

  @override
  void didUpdateWidget(WeatherHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showWeather && !oldWidget.showWeather) {
      _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    final weather = await _weatherService.getCurrentWeather();
    if (!mounted) return;

    // Kalau gagal load, matikan toggle cuaca
    if (weather == null) {
      final settingsBox = Hive.box('settingsBox');
      await settingsBox.put('showWeather', false);
      return;
    }

    setState(() => _weather = weather);
  }

  @override
  Widget build(BuildContext context) {
    // Kalau semua toggle mati, return empty
    if (!widget.showDate && !widget.showTime && !widget.showWeather) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final currentLocale = Localizations.localeOf(context).toString();

    final dayStr = DateFormat('EEEE', currentLocale).format(now).toUpperCase();
    final dateStr = DateFormat('d MMM yyyy', currentLocale).format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    final greeting = _getGreeting(context, now.hour);
    final userName = Hive.box(
      'settingsBox',
    ).get('userName', defaultValue: 'Feri');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // === KIRI ===
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'DMSerifDisplay',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.showDate) ...[
                  Text(
                    '$dayStr, $dateStr',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (widget.showTime)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // === KANAN ===
          if (widget.showWeather && _weather != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  _getWeatherIcon(_weather!.iconCode),
                  color: AppColors.systemYellow,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_weather!.temperature.round()}°C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _capitalize(_weather!.condition),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _weather!.cityName,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          else if (widget.showWeather && _weather == null)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context, int hour) {
    final l10n = AppLocalizations.of(context)!;
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 18) return l10n.greetingAfternoon;
    if (hour >= 18 && hour < 22) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny_outlined;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud_outlined;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
