import 'dart:math';
import '../../features/weather/domain/entities/weather_entity.dart';
import '../../features/weather/domain/entities/forecast_entity.dart';
import '../../features/weather/domain/entities/air_quality_entity.dart';
import '../../features/weather/domain/entities/astronomy_entity.dart';

class MockWeatherHelper {
  static final Random _rand = Random();

  static List<String> get mockCities => ['New York', 'London', 'Tokyo', 'Paris', 'Sydney'];

  static double _getLat(String city) {
    switch (city.toLowerCase()) {
      case 'new york': return 40.7128;
      case 'london': return 51.5074;
      case 'tokyo': return 35.6762;
      case 'paris': return 48.8566;
      case 'sydney': return -33.8688;
      default: return 0.0;
    }
  }

  static double _getLon(String city) {
    switch (city.toLowerCase()) {
      case 'new york': return -74.0060;
      case 'london': return -0.1278;
      case 'tokyo': return 139.6503;
      case 'paris': return 2.3522;
      case 'sydney': return 151.2093;
      default: return 0.0;
    }
  }

  static WeatherEntity generateMockWeather(String city) {
    final lat = _getLat(city);
    final lon = _getLon(city);
    
    // Choose weather conditions based on city to create variation
    String condition = 'Clear';
    String description = 'clear sky';
    String icon = '01d';
    double temp = 22.0;
    double feels = 21.5;
    double min = 16.0;
    double max = 26.0;
    int humidity = 55;
    int pressure = 1016;
    double windSpeed = 3.5;
    int windDir = 180;
    double uv = 4.2;
    double visibility = 10000;
    int clouds = 5;

    final lowerCity = city.toLowerCase();
    if (lowerCity == 'london') {
      condition = 'Clouds';
      description = 'broken clouds';
      icon = '04d';
      temp = 14.5;
      feels = 13.8;
      min = 10.0;
      max = 18.0;
      humidity = 82;
      pressure = 1009;
      windSpeed = 5.2;
      windDir = 240;
      uv = 2.1;
      clouds = 75;
    } else if (lowerCity == 'new york') {
      condition = 'Rain';
      description = 'moderate rain';
      icon = '10d';
      temp = 18.0;
      feels = 18.2;
      min = 14.0;
      max = 21.0;
      humidity = 90;
      pressure = 1005;
      windSpeed = 6.4;
      windDir = 90;
      uv = 1.5;
      clouds = 95;
    } else if (lowerCity == 'tokyo') {
      condition = 'Clear';
      description = 'clear sky';
      icon = '01d';
      temp = 24.0;
      feels = 23.5;
      min = 18.0;
      max = 28.5;
      humidity = 48;
      pressure = 1018;
      windSpeed = 2.1;
      windDir = 120;
      uv = 6.8;
      clouds = 0;
    } else if (lowerCity == 'paris') {
      condition = 'Fog';
      description = 'misty haze';
      icon = '50d';
      temp = 12.0;
      feels = 11.5;
      min = 8.0;
      max = 15.0;
      humidity = 95;
      pressure = 1012;
      windSpeed = 1.8;
      windDir = 300;
      uv = 1.0;
      clouds = 80;
    } else if (lowerCity == 'sydney') {
      condition = 'Thunderstorm';
      description = 'thunderstorm with rain';
      icon = '11d';
      temp = 26.5;
      feels = 28.0;
      min = 20.0;
      max = 30.0;
      humidity = 78;
      pressure = 1002;
      windSpeed = 8.5;
      windDir = 160;
      uv = 8.5;
      clouds = 90;
    }

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return WeatherEntity(
      cityName: city,
      latitude: lat,
      longitude: lon,
      temp: temp,
      feelsLike: feels,
      tempMin: min,
      tempMax: max,
      condition: condition,
      description: description,
      iconCode: icon,
      humidity: humidity,
      pressure: pressure,
      windSpeed: windSpeed,
      windDirection: windDir,
      visibility: visibility,
      cloudCover: clouds,
      dewPoint: temp - ((100 - humidity) / 5),
      rainProbability: condition == 'Rain' ? 0.85 : (condition == 'Thunderstorm' ? 0.90 : 0.10),
      uvIndex: uv,
      sunrise: nowSec - 28800, // 8 hours ago
      sunset: nowSec + 14400,  // 4 hours later
      timestamp: nowSec,
    );
  }

  static ForecastEntity generateMockForecast(String city) {
    final now = DateTime.now();
    final List<HourlyForecastEntity> hourly = [];
    final List<DailyForecastEntity> daily = [];

    // Base temperature for the city to build predictions off
    double baseTemp = 20.0;
    String baseCond = 'Clear';
    String baseIcon = '01d';

    final lowerCity = city.toLowerCase();
    if (lowerCity == 'london') {
      baseTemp = 14.5;
      baseCond = 'Clouds';
      baseIcon = '04d';
    } else if (lowerCity == 'new york') {
      baseTemp = 18.0;
      baseCond = 'Rain';
      baseIcon = '10d';
    } else if (lowerCity == 'tokyo') {
      baseTemp = 24.0;
      baseCond = 'Clear';
      baseIcon = '01d';
    } else if (lowerCity == 'paris') {
      baseTemp = 12.0;
      baseCond = 'Fog';
      baseIcon = '50d';
    } else if (lowerCity == 'sydney') {
      baseTemp = 26.5;
      baseCond = 'Thunderstorm';
      baseIcon = '11d';
    }

    // Generate 24 hours (hourly)
    for (int i = 0; i < 24; i++) {
      final forecastTime = now.add(Duration(hours: i));
      final hourSec = forecastTime.millisecondsSinceEpoch ~/ 1000;
      
      // Calculate smooth temp wave based on hour
      final double hourFactor = sin((forecastTime.hour - 6) / 24.0 * 2 * pi); // Peaks at 14:00 (2pm)
      final temp = baseTemp + (hourFactor * 4.0) + (_rand.nextDouble() - 0.5);

      hourly.add(HourlyForecastEntity(
        timestamp: hourSec,
        temp: double.parse(temp.toStringAsFixed(1)),
        condition: baseCond,
        iconCode: _getIconByHour(baseIcon, forecastTime.hour),
        rainProbability: baseCond == 'Rain' ? 0.8 : (baseCond == 'Thunderstorm' ? 0.9 : 0.05),
        windSpeed: 3.0 + i % 4,
      ));
    }

    // Generate 10 days (daily)
    final conditions = ['Clear', 'Clouds', 'Rain', 'Thunderstorm', 'Snow', 'Fog'];
    final descriptions = [
      'clear sky',
      'broken clouds',
      'light rain',
      'severe storm',
      'heavy snow',
      'dense fog'
    ];
    final icons = ['01d', '03d', '10d', '11d', '13d', '50d'];

    for (int i = 0; i < 10; i++) {
      final forecastDay = now.add(Duration(days: i));
      final daySec = forecastDay.millisecondsSinceEpoch ~/ 1000;

      // Select a condition with some variation based on base city
      int condIdx = 0;
      if (i > 0) {
        condIdx = _rand.nextInt(conditions.length);
        if (_rand.nextDouble() < 0.4) {
          // 40% bias toward the city's base condition
          condIdx = conditions.indexOf(baseCond);
          if (condIdx == -1) condIdx = 0;
        }
      } else {
        condIdx = conditions.indexOf(baseCond);
        if (condIdx == -1) condIdx = 0;
      }

      final double dayFactor = sin(i / 10.0 * pi);
      final double dev = (_rand.nextDouble() - 0.5) * 3;
      final maxTemp = baseTemp + 5 + dayFactor + dev;
      final minTemp = baseTemp - 5 - dayFactor + dev;

      daily.add(DailyForecastEntity(
        timestamp: daySec,
        tempMin: double.parse(minTemp.toStringAsFixed(1)),
        tempMax: double.parse(maxTemp.toStringAsFixed(1)),
        tempDay: double.parse(((minTemp + maxTemp) / 2).toStringAsFixed(1)),
        condition: conditions[condIdx],
        description: descriptions[condIdx],
        iconCode: icons[condIdx],
        humidity: 50 + _rand.nextInt(40),
        pressure: 1000 + _rand.nextInt(20),
        windSpeed: 2.0 + _rand.nextDouble() * 8.0,
        windDirection: _rand.nextInt(360),
        rainProbability: conditions[condIdx] == 'Rain' || conditions[condIdx] == 'Thunderstorm' ? 0.8 : 0.1,
        sunrise: daySec + 21600, // 6:00 AM
        sunset: daySec + 72000,  // 8:00 PM
      ));
    }

    return ForecastEntity(hourly: hourly, daily: daily);
  }

  static AirQualityEntity generateMockAirQuality(String city) {
    int aqi = 1;
    double pm2_5 = 4.2;
    double pm10 = 8.5;
    double co = 210.0;
    double no2 = 12.0;
    double so2 = 3.5;
    double o3 = 45.0;

    final lowerCity = city.toLowerCase();
    if (lowerCity == 'london') {
      aqi = 2;
      pm2_5 = 12.4;
      pm10 = 22.0;
      co = 280.0;
      no2 = 24.5;
      so2 = 6.2;
      o3 = 55.0;
    } else if (lowerCity == 'new york') {
      aqi = 3;
      pm2_5 = 38.5;
      pm10 = 48.0;
      co = 450.0;
      no2 = 42.0;
      so2 = 12.8;
      o3 = 70.0;
    } else if (lowerCity == 'tokyo') {
      aqi = 2;
      pm2_5 = 14.8;
      pm10 = 28.0;
      co = 320.0;
      no2 = 28.0;
      so2 = 5.5;
      o3 = 62.0;
    } else if (lowerCity == 'paris') {
      aqi = 4;
      pm2_5 = 62.5;
      pm10 = 85.0;
      co = 720.0;
      no2 = 68.0;
      so2 = 24.2;
      o3 = 90.0;
    } else if (lowerCity == 'sydney') {
      aqi = 1;
      pm2_5 = 3.1;
      pm10 = 5.2;
      co = 180.0;
      no2 = 6.4;
      so2 = 1.2;
      o3 = 35.0;
    }

    return AirQualityEntity(
      aqi: aqi,
      co: co,
      no2: no2,
      o3: o3,
      so2: so2,
      pm2_5: pm2_5,
      pm10: pm10,
      nh3: 0.8,
      no: 1.2,
    );
  }

  static AstronomyEntity generateMockAstronomy(String city) {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Choose different moon phases based on city to show UI variation
    double phase = 0.5; // Full moon
    final lowerCity = city.toLowerCase();
    if (lowerCity == 'london') phase = 0.0;   // New moon
    if (lowerCity == 'new york') phase = 0.15; // Waxing crescent
    if (lowerCity == 'tokyo') phase = 0.25;    // First quarter
    if (lowerCity == 'paris') phase = 0.75;    // Third quarter
    if (lowerCity == 'sydney') phase = 0.85;   // Waning crescent

    return AstronomyEntity(
      sunrise: nowSec - 28800, // 8 hours ago
      sunset: nowSec + 14400,  // 4 hours later
      moonrise: nowSec - 7200,  // 2 hours ago
      moonset: nowSec + 36000, // 10 hours later
      moonPhase: phase,
    );
  }

  static String _getIconByHour(String baseIcon, int hour) {
    final isNight = hour < 6 || hour > 18;
    if (isNight) {
      return baseIcon.replaceAll('d', 'n');
    }
    return baseIcon.replaceAll('n', 'd');
  }
}
