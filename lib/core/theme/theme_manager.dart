import 'package:flutter/material.dart';

enum WeatherThemeType {
  morning,
  afternoon,
  sunset,
  night,
  rain,
  storm,
  snow,
  fog,
}

class WeatherThemeData {
  final WeatherThemeType type;
  final String name;
  final List<Color> backgroundGradient;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color cardColor;
  final bool isDark;

  WeatherThemeData({
    required this.type,
    required this.name,
    required this.backgroundGradient,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.cardColor,
    required this.isDark,
  });
}

class ThemeManager extends ChangeNotifier {
  WeatherThemeType _currentThemeType = WeatherThemeType.afternoon;

  WeatherThemeType get currentThemeType => _currentThemeType;

  void updateThemeByCondition(String condition, {int? timestamp, int? sunrise, int? sunset}) {
    final now = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : DateTime.now();

    final isNightTime = _checkIsNight(now, sunrise, sunset);
    final themeType = _determineThemeType(condition, isNightTime, now);
    
    setTheme(themeType);
  }

  bool _checkIsNight(DateTime now, int? sunriseSec, int? sunsetSec) {
    if (sunriseSec != null && sunsetSec != null) {
      final sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseSec * 1000);
      final sunset = DateTime.fromMillisecondsSinceEpoch(sunsetSec * 1000);
      return now.isBefore(sunrise) || now.isAfter(sunset);
    }
    // Fallback if sunrise/sunset is not supplied
    final hour = now.hour;
    return hour < 6 || hour > 18;
  }

  WeatherThemeType _determineThemeType(String condition, bool isNight, DateTime now) {
    final cond = condition.toLowerCase();

    // Check atmospheric conditions first
    if (cond.contains('thunderstorm') || cond.contains('tornado') || cond.contains('squall')) {
      return WeatherThemeType.storm;
    } else if (cond.contains('rain') || cond.contains('drizzle')) {
      return WeatherThemeType.rain;
    } else if (cond.contains('snow') || cond.contains('sleet') || cond.contains('hail')) {
      return WeatherThemeType.snow;
    } else if (cond.contains('fog') || cond.contains('mist') || cond.contains('haze') || cond.contains('smoke') || cond.contains('dust') || cond.contains('ash')) {
      return WeatherThemeType.fog;
    }

    // Default clear/cloudy depending on time of day
    if (isNight) {
      return WeatherThemeType.night;
    }

    final hour = now.hour;
    if (hour >= 6 && hour < 11) {
      return WeatherThemeType.morning;
    } else if (hour >= 11 && hour < 16) {
      return WeatherThemeType.afternoon;
    } else if (hour >= 16 && hour <= 18) {
      return WeatherThemeType.sunset;
    } else {
      return WeatherThemeType.night;
    }
  }

  void setTheme(WeatherThemeType themeType) {
    if (_currentThemeType != themeType) {
      _currentThemeType = themeType;
      notifyListeners();
    }
  }

  WeatherThemeData get currentTheme {
    switch (_currentThemeType) {
      case WeatherThemeType.morning:
        return WeatherThemeData(
          type: WeatherThemeType.morning,
          name: 'Morning Glow',
          backgroundGradient: [
            const Color(0xFFFDC830), // Sunny yellow
            const Color(0xFFF37335), // Orange sunset/sunrise hue
          ],
          primaryColor: const Color(0xFFF37335),
          accentColor: const Color(0xFFFDC830),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.08),
          isDark: false,
        );
      case WeatherThemeType.afternoon:
        return WeatherThemeData(
          type: WeatherThemeType.afternoon,
          name: 'Clear Afternoon',
          backgroundGradient: [
            const Color(0xFF2193b0), // Sky blue
            const Color(0xFF6dd5ed), // Cyan light
          ],
          primaryColor: const Color(0xFF2193b0),
          accentColor: const Color(0xFF6dd5ed),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.08),
          isDark: false,
        );
      case WeatherThemeType.sunset:
        return WeatherThemeData(
          type: WeatherThemeType.sunset,
          name: 'Golden Sunset',
          backgroundGradient: [
            const Color(0xFF4568DC), // Deep blue-violet
            const Color(0xFFB06AB3), // Magenta-orange hue
          ],
          primaryColor: const Color(0xFFB06AB3),
          accentColor: const Color(0xFF4568DC),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.08),
          isDark: true,
        );
      case WeatherThemeType.night:
        return WeatherThemeData(
          type: WeatherThemeType.night,
          name: 'Starry Night',
          backgroundGradient: [
            const Color(0xFF0F2027), // Deep slate blue
            const Color(0xFF203A43), // Deep sea blue
            const Color(0xFF2C5364), // Dark steel blue
          ],
          primaryColor: const Color(0xFF2C5364),
          accentColor: const Color(0xFF0F2027),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.05),
          isDark: true,
        );
      case WeatherThemeType.rain:
        return WeatherThemeData(
          type: WeatherThemeType.rain,
          name: 'Rainy Shower',
          backgroundGradient: [
            const Color(0xFF373B44), // Slate gray
            const Color(0xFF4286f4), // Water blue
          ],
          primaryColor: const Color(0xFF4286f4),
          accentColor: const Color(0xFF373B44),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.06),
          isDark: true,
        );
      case WeatherThemeType.storm:
        return WeatherThemeData(
          type: WeatherThemeType.storm,
          name: 'Thunderstorm',
          backgroundGradient: [
            const Color(0xFF1F1C2C), // Deep black-violet
            const Color(0xFF928DAB), // Dark mist purple
          ],
          primaryColor: const Color(0xFF1F1C2C),
          accentColor: const Color(0xFF928DAB),
          textColor: Colors.white,
          cardColor: Colors.white.withOpacity(0.05),
          isDark: true,
        );
      case WeatherThemeType.snow:
        return WeatherThemeData(
          type: WeatherThemeType.snow,
          name: 'Blizzard Snow',
          backgroundGradient: [
            const Color(0xFF83a4d4), // Ice blue
            const Color(0xFFb6fbff), // Powder white
          ],
          primaryColor: const Color(0xFF83a4d4),
          accentColor: const Color(0xFFb6fbff),
          textColor: Colors.black87,
          cardColor: Colors.white.withOpacity(0.12),
          isDark: false,
        );
      case WeatherThemeType.fog:
        return WeatherThemeData(
          type: WeatherThemeType.fog,
          name: 'Foggy Haze',
          backgroundGradient: [
            const Color(0xFF757F9A), // Misty blue-gray
            const Color(0xFFD7DDE8), // Light silver-gray
          ],
          primaryColor: const Color(0xFF757F9A),
          accentColor: const Color(0xFFD7DDE8),
          textColor: Colors.black87,
          cardColor: Colors.white.withOpacity(0.10),
          isDark: false,
        );
    }
  }

  ThemeData get currentThemeData {
    final theme = currentTheme;
    final baseTheme = theme.isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      primaryColor: theme.primaryColor,
      scaffoldBackgroundColor: Colors.transparent, // Always transparent so the background gradient shows
      cardColor: theme.cardColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.primaryColor,
        brightness: theme.isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: theme.textColor,
        displayColor: theme.textColor,
      ),
    );
  }
}
