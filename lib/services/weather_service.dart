import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String iconCode;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.cityName,
  });
}

class WeatherService {
  // ⚠️ GANTI DENGAN API KEY KAMU
  static const String _apiKey = '80cd5a82b21c5e42996cafbe7fb0a17f';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Ambil data cuaca berdasarkan lokasi user.
  Future<WeatherData?> getCurrentWeather() async {
    try {
      // 1. Cek izin lokasi (HANYA CEK, TIDAK MINTA)
      final permission = await _checkLocationPermission();
      if (!permission) return null;

      // 2. Dapatkan posisi user
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 3. Request cuaca ke OpenWeatherMap
      final url = Uri.parse(
        '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=id',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      return WeatherData(
        temperature: (data['main']['temp'] as num).toDouble(),
        condition: data['weather'][0]['description'] as String,
        iconCode: data['weather'][0]['icon'] as String,
        cityName: data['name'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cek izin lokasi. (TANPA MEMINTA IZIN)
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    // Hanya cek status permission saat ini
    LocationPermission permission = await Geolocator.checkPermission();

    // Jika belum diizinkan, langsung kembalikan false (jangan minta izin)
    if (permission == LocationPermission.denied) return false;
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }
}
