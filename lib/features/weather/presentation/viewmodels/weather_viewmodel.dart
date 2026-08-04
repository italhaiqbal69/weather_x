import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/helpers/mock_weather_helper.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../domain/entities/air_quality_entity.dart';
import '../../domain/entities/astronomy_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository;
  final LocationService _locationService;
  final HiveStorage _hiveStorage;

  WeatherViewModel({
    required WeatherRepository repository,
    required LocationService locationService,
    required HiveStorage hiveStorage,
  })  : _repository = repository,
        _locationService = locationService,
        _hiveStorage = hiveStorage {
    _loadFavoritesFromStorage();
  }

  WeatherStatus _status = WeatherStatus.initial;
  WeatherStatus get status => _status;

  bool get isLoading => _status == WeatherStatus.loading;
  bool get isSuccess => _status == WeatherStatus.success;
  bool get isError => _status == WeatherStatus.error;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Active City weather states
  WeatherEntity? _currentWeather;
  WeatherEntity? get currentWeather => _currentWeather;

  ForecastEntity? _forecast;
  ForecastEntity? get forecast => _forecast;

  AirQualityEntity? _airQuality;
  AirQualityEntity? get airQuality => _airQuality;

  AstronomyEntity? _astronomy;
  AstronomyEntity? get astronomy => _astronomy;

  // Swipeable multiple cities support
  int _activeCityIndex = 0;
  int get activeCityIndex => _activeCityIndex;

  List<String> _favoriteCityNames = [];
  List<String> get favoriteCityNames => _favoriteCityNames;

  List<WeatherEntity> _citiesWeatherList = [];
  List<WeatherEntity> get citiesWeatherList => _citiesWeatherList;

  void setActiveCityIndex(int index) {
    if (index >= 0 && index < _citiesWeatherList.length) {
      _activeCityIndex = index;
      _updateActiveWeatherState();
      notifyListeners();
    }
  }

  void _loadFavoritesFromStorage() {
    final list = _hiveStorage.get(AppConstants.favoritesBoxName, 'list');
    if (list != null && list is List) {
      _favoriteCityNames = List<String>.from(list);
    } else {
      // Default initial favorites
      _favoriteCityNames = ['London', 'Tokyo', 'Paris'];
      _saveFavoritesToStorage();
    }
  }

  Future<void> _saveFavoritesToStorage() async {
    await _hiveStorage.save(AppConstants.favoritesBoxName, 'list', _favoriteCityNames);
  }

  void _updateActiveWeatherState() {
    if (_citiesWeatherList.isEmpty) return;
    _currentWeather = _citiesWeatherList[_activeCityIndex];
    
    // Trigger theme update globally based on current weather condition
    sl<ThemeManager>().updateThemeByCondition(
      _currentWeather!.condition,
      timestamp: _currentWeather!.timestamp,
      sunrise: _currentWeather!.sunrise,
      sunset: _currentWeather!.sunset,
    );
  }

  // Primary load: Fetches GPS and all favorites
  Future<void> loadAllWeatherData({bool forceRefresh = false}) async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<WeatherEntity> loadedWeather = [];

      // 1. Fetch GPS Location weather
      try {
        final position = await _locationService.getCurrentPosition();
        final gpsWeather = await _repository.getWeather(position.latitude, position.longitude, forceRefresh: forceRefresh);
        loadedWeather.add(gpsWeather);
      } catch (e) {
        developer.log('GPS Fetch failed, using cached fallback: $e');
        // Add a mock Current Location if GPS fails completely
        loadedWeather.add(MockWeatherHelper.generateMockWeather('New York'));
      }

      // 2. Fetch Favorites weather
      for (final city in _favoriteCityNames) {
        try {
          final cityWeather = await _repository.getWeatherByCity(city, forceRefresh: forceRefresh);
          loadedWeather.add(cityWeather);
        } catch (e) {
          developer.log('Failed fetching weather for $city: $e');
        }
      }

      _citiesWeatherList = loadedWeather;
      
      // Ensure bounds checking
      if (_activeCityIndex >= _citiesWeatherList.length) {
        _activeCityIndex = 0;
      }

      _updateActiveWeatherState();

      // 3. Load forecasts & extras for active city
      await _loadSecondaryActiveData(forceRefresh: forceRefresh);

      _status = WeatherStatus.success;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _loadSecondaryActiveData({bool forceRefresh = false}) async {
    if (_currentWeather == null) return;
    
    final lat = _currentWeather!.latitude;
    final lon = _currentWeather!.longitude;

    try {
      _forecast = await _repository.getForecast(lat, lon, forceRefresh: forceRefresh);
      _airQuality = await _repository.getAirQuality(lat, lon, forceRefresh: forceRefresh);
      _astronomy = await _repository.getAstronomy(lat, lon, forceRefresh: forceRefresh);
    } catch (e) {
      developer.log('Error loading secondary forecast/AQI/astronomy: $e');
      // If live fails, fetch mock so the user sees a rich page
      _forecast = MockWeatherHelper.generateMockForecast(_currentWeather!.cityName);
      _airQuality = MockWeatherHelper.generateMockAirQuality(_currentWeather!.cityName);
      _astronomy = MockWeatherHelper.generateMockAstronomy(_currentWeather!.cityName);
    }
  }

  Future<void> refreshActiveCity() async {
    if (_currentWeather == null) return;
    
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      final lat = _currentWeather!.latitude;
      final lon = _currentWeather!.longitude;
      final isGps = _activeCityIndex == 0;

      WeatherEntity updated;
      if (isGps) {
        final position = await _locationService.getCurrentPosition();
        updated = await _repository.getWeather(position.latitude, position.longitude, forceRefresh: true);
      } else {
        updated = await _repository.getWeatherByCity(_currentWeather!.cityName, forceRefresh: true);
      }

      _citiesWeatherList[_activeCityIndex] = updated;
      _updateActiveWeatherState();

      await _loadSecondaryActiveData(forceRefresh: true);

      _status = WeatherStatus.success;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> addFavoriteCity(String city) async {
    if (city.isEmpty) return;
    
    // Standardize
    final cleanCity = city.trim();
    if (_favoriteCityNames.any((c) => c.toLowerCase() == cleanCity.toLowerCase())) {
      return; // Already present
    }

    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      // Validate with API call
      final weather = await _repository.getWeatherByCity(cleanCity, forceRefresh: true);
      
      _favoriteCityNames.add(weather.cityName);
      await _saveFavoritesToStorage();

      _citiesWeatherList.add(weather);
      
      // Auto transition to newly added favorite
      _activeCityIndex = _citiesWeatherList.length - 1;
      _updateActiveWeatherState();
      
      await _loadSecondaryActiveData(forceRefresh: true);
      
      _status = WeatherStatus.success;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = 'Could not add $city: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> removeFavoriteCity(int index) async {
    // Offset by 1 because index 0 is Current Location (GPS)
    if (index <= 0 || index >= _citiesWeatherList.length) return;

    final cityName = _citiesWeatherList[index].cityName;
    _favoriteCityNames.removeWhere((c) => c.toLowerCase() == cityName.toLowerCase());
    await _saveFavoritesToStorage();

    _citiesWeatherList.removeAt(index);

    // Reposition active pointer
    if (_activeCityIndex >= _citiesWeatherList.length) {
      _activeCityIndex = _citiesWeatherList.length - 1;
    }
    _updateActiveWeatherState();
    
    await _loadSecondaryActiveData();
    notifyListeners();
  }

  Future<void> reorderFavorites(int oldIndex, int newIndex) async {
    // Account for GPS at index 0 which is locked
    if (oldIndex == 0 || newIndex == 0) return;
    if (oldIndex >= _citiesWeatherList.length || newIndex >= _citiesWeatherList.length) return;

    final item = _citiesWeatherList.removeAt(oldIndex);
    _citiesWeatherList.insert(newIndex, item);

    // Update favorite strings order
    final favOldIdx = oldIndex - 1;
    final favNewIdx = newIndex - 1;
    final favName = _favoriteCityNames.removeAt(favOldIdx);
    _favoriteCityNames.insert(favNewIdx, favName);
    
    await _saveFavoritesToStorage();

    // Adjust active index
    if (_activeCityIndex == oldIndex) {
      _activeCityIndex = newIndex;
    } else if (_activeCityIndex > oldIndex && _activeCityIndex <= newIndex) {
      _activeCityIndex--;
    } else if (_activeCityIndex < oldIndex && _activeCityIndex >= newIndex) {
      _activeCityIndex++;
    }

    _updateActiveWeatherState();
    notifyListeners();
  }
}
