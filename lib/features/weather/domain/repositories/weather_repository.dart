import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/air_quality_entity.dart';
import '../../domain/entities/astronomy_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getWeather(double lat, double lon, {bool forceRefresh = false});
  Future<WeatherEntity> getWeatherByCity(String city, {bool forceRefresh = false});
  
  Future<ForecastEntity> getForecast(double lat, double lon, {bool forceRefresh = false});
  Future<ForecastEntity> getForecastByCity(String city, {bool forceRefresh = false});
  
  Future<AirQualityEntity> getAirQuality(double lat, double lon, {bool forceRefresh = false});
  Future<AstronomyEntity> getAstronomy(double lat, double lon, {bool forceRefresh = false});
  
  Future<List<String>> searchCities(String query);
  
  Future<Map<String, dynamic>> getRoute(double startLat, double startLon, double endLat, double endLon);
}
