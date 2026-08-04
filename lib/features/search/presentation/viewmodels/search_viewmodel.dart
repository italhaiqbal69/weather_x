import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../weather/domain/repositories/weather_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final WeatherRepository _repository;
  final HiveStorage _hiveStorage;

  SearchViewModel({
    required WeatherRepository repository,
    required HiveStorage hiveStorage,
  })  : _repository = repository,
        _hiveStorage = hiveStorage {
    _loadHistory();
  }

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  String? _searchError;
  String? get searchError => _searchError;

  void _loadHistory() {
    final list = _hiveStorage.get(AppConstants.favoritesBoxName, 'search_history');
    if (list != null && list is List) {
      _recentSearches = List<String>.from(list);
    }
  }

  Future<void> _saveHistory() async {
    await _hiveStorage.save(AppConstants.favoritesBoxName, 'search_history', _recentSearches);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _suggestions = await _repository.searchCities(query.trim());
      if (_suggestions.isEmpty) {
        _searchError = 'No locations found matching "$query".';
      }
    } catch (e) {
      _searchError = 'Error seeking locations: ${e.toString()}';
      _suggestions = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(String city) async {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return;

    _recentSearches.removeWhere((c) => c.toLowerCase() == cleanCity.toLowerCase());
    _recentSearches.insert(0, cleanCity);

    // Limit to 10 entries
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeFromHistory(String city) async {
    _recentSearches.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _recentSearches = [];
    await _saveHistory();
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    _searchError = null;
    notifyListeners();
  }
}
