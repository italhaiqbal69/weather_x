import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../exceptions/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getCurrentWeatherByCity(String city) async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/weather',
        queryParameters: {
          'q': city,
          'units': 'metric',
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getForecastByCity(String city) async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/forecast',
        queryParameters: {
          'q': city,
          'units': 'metric',
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getAirPollution(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/air_pollution',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<List<dynamic>> searchCities(String query) async {
    try {
      final response = await _dio.get(
        AppConstants.geoBaseUrl + '/direct',
        queryParameters: {
          'q': query,
          'limit': 5,
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<List<dynamic>> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get(
        AppConstants.geoBaseUrl + '/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'limit': 5,
          'appid': AppConstants.openWeatherApiKey,
        },
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> fetchRoute(double startLat, double startLon, double endLat, double endLon) async {
    try {
      final response = await _dio.get(
        '${AppConstants.osrmRouteUrl}/$startLon,$startLat;$endLon,$endLat',
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Invalid API Key. Please verify your OpenWeather credentials.';
        } else if (code == 404) {
          return 'Location not found. Please try a different search.';
        }
        return 'Server returned error status code: $code';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection detected.';
      default:
        return 'An unexpected network error occurred.';
    }
  }
}
