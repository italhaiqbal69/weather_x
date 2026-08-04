import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/storage/hive_storage.dart';

enum TemperatureUnit { celsius, fahrenheit }
enum WindSpeedUnit { kmh, mph, ms }
enum PressureUnit { hpa, inhg }

class SettingsViewModel extends ChangeNotifier {
  final HiveStorage _hiveStorage;

  SettingsViewModel({required HiveStorage hiveStorage}) : _hiveStorage = hiveStorage {
    _loadSettings();
  }

  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  TemperatureUnit get tempUnit => _tempUnit;

  WindSpeedUnit _windUnit = WindSpeedUnit.kmh;
  WindSpeedUnit get windUnit => _windUnit;

  PressureUnit _pressureUnit = PressureUnit.hpa;
  PressureUnit get pressureUnit => _pressureUnit;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _autoRefresh = true;
  bool get autoRefresh => _autoRefresh;

  int _refreshIntervalMinutes = 30;
  int get refreshIntervalMinutes => _refreshIntervalMinutes;

  String _geminiApiKey = '';
  String get geminiApiKey => _geminiApiKey;

  void _loadSettings() {
    final tempStr = _hiveStorage.get(AppConstants.settingsBoxName, AppConstants.keyTempUnit, defaultValue: 'celsius');
    _tempUnit = tempStr == 'fahrenheit' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;

    final windStr = _hiveStorage.get(AppConstants.settingsBoxName, AppConstants.keyWindUnit, defaultValue: 'kmh');
    if (windStr == 'mph') {
      _windUnit = WindSpeedUnit.mph;
    } else if (windStr == 'ms') {
      _windUnit = WindSpeedUnit.ms;
    } else {
      _windUnit = WindSpeedUnit.kmh;
    }

    final pressStr = _hiveStorage.get(AppConstants.settingsBoxName, AppConstants.keyPressureUnit, defaultValue: 'hpa');
    _pressureUnit = pressStr == 'inhg' ? PressureUnit.inhg : PressureUnit.hpa;

    _notificationsEnabled = _hiveStorage.get(AppConstants.settingsBoxName, 'notifications_enabled', defaultValue: true) as bool;
    _autoRefresh = _hiveStorage.get(AppConstants.settingsBoxName, 'auto_refresh', defaultValue: true) as bool;
    _refreshIntervalMinutes = _hiveStorage.get(AppConstants.settingsBoxName, 'refresh_interval', defaultValue: 30) as int;
    _geminiApiKey = _hiveStorage.get(AppConstants.settingsBoxName, AppConstants.keyGeminiApiKey, defaultValue: '') as String;
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    _tempUnit = unit;
    await _hiveStorage.save(AppConstants.settingsBoxName, AppConstants.keyTempUnit, unit.name);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    _windUnit = unit;
    await _hiveStorage.save(AppConstants.settingsBoxName, AppConstants.keyWindUnit, unit.name);
    notifyListeners();
  }

  Future<void> setPressureUnit(PressureUnit unit) async {
    _pressureUnit = unit;
    await _hiveStorage.save(AppConstants.settingsBoxName, AppConstants.keyPressureUnit, unit.name);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _hiveStorage.save(AppConstants.settingsBoxName, 'notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleAutoRefresh(bool enabled) async {
    _autoRefresh = enabled;
    await _hiveStorage.save(AppConstants.settingsBoxName, 'auto_refresh', enabled);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int minutes) async {
    _refreshIntervalMinutes = minutes;
    await _hiveStorage.save(AppConstants.settingsBoxName, 'refresh_interval', minutes);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    await _hiveStorage.save(AppConstants.settingsBoxName, AppConstants.keyGeminiApiKey, key);
    notifyListeners();
  }

  // Unit helper conversions
  String formatTemperature(double celsius) {
    if (_tempUnit == TemperatureUnit.fahrenheit) {
      final f = (celsius * 9 / 5) + 32;
      return '${f.toStringAsFixed(0)}°F';
    }
    return '${celsius.toStringAsFixed(0)}°C';
  }

  String formatWindSpeed(double msSpeed) {
    switch (_windUnit) {
      case WindSpeedUnit.kmh:
        final kmh = msSpeed * 3.6;
        return '${kmh.toStringAsFixed(1)} km/h';
      case WindSpeedUnit.mph:
        final mph = msSpeed * 2.237;
        return '${mph.toStringAsFixed(1)} mph';
      case WindSpeedUnit.ms:
        return '${msSpeed.toStringAsFixed(1)} m/s';
    }
  }

  String formatPressure(int hpa) {
    if (_pressureUnit == PressureUnit.inhg) {
      final inhg = hpa * 0.02953;
      return '${inhg.toStringAsFixed(2)} inHg';
    }
    return '$hpa hPa';
  }

  Future<void> clearAllCache() async {
    await _hiveStorage.clear(AppConstants.weatherBoxName);
  }
}
