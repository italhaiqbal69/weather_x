import 'package:flutter_test/flutter_test.dart';
import 'package:weather_x/core/helpers/mock_weather_helper.dart';
import 'package:weather_x/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_x/features/weather/domain/entities/forecast_entity.dart';
import 'package:weather_x/features/weather/domain/entities/air_quality_entity.dart';
import 'package:weather_x/features/weather/domain/entities/astronomy_entity.dart';

void main() {
  group('WeatherX Model Parsing and Mock Data Tests', () {
    test('generateMockWeather returns correct entity with details', () {
      final city = 'London';
      final weather = MockWeatherHelper.generateMockWeather(city);

      expect(weather.cityName, equals('London'));
      expect(weather.latitude, equals(51.5074));
      expect(weather.longitude, equals(-0.1278));
      expect(weather.condition, equals('Clouds'));
      expect(weather.humidity, equals(82));
      expect(weather.temp, equals(14.5));
    });

    test('generateMockForecast outputs hourly and daily intervals', () {
      final city = 'Tokyo';
      final forecast = MockWeatherHelper.generateMockForecast(city);

      expect(forecast.hourly.length, equals(24));
      expect(forecast.daily.length, equals(10));
      expect(forecast.daily.first.condition, equals('Clear'));
    });

    test('generateMockAirQuality outputs accurate components', () {
      final city = 'Paris';
      final aqi = MockWeatherHelper.generateMockAirQuality(city);

      expect(aqi.aqi, equals(4)); // Poor air quality in Paris mock
      expect(aqi.statusName, equals('Poor'));
      expect(aqi.pm2_5, equals(62.5));
    });

    test('generateMockAstronomy calculates correct solar intervals', () {
      final city = 'New York';
      final astronomy = MockWeatherHelper.generateMockAstronomy(city);

      expect(astronomy.moonPhaseDescription, equals('Waxing Crescent'));
      expect(astronomy.goldenHourMorning, isNotEmpty);
      expect(astronomy.blueHourEvening, isNotEmpty);
    });

    test('toJson and fromJson serializes WeatherEntity correctly', () {
      final city = 'Sydney';
      final original = MockWeatherHelper.generateMockWeather(city);
      final json = original.toJson();
      final parsed = WeatherEntity.fromJson(json);

      expect(parsed.cityName, equals(original.cityName));
      expect(parsed.temp, equals(original.temp));
      expect(parsed.feelsLike, equals(original.feelsLike));
      expect(parsed.condition, equals(original.condition));
    });
  });
}
