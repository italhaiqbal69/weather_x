import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_background_widget.dart';
import '../../../../core/theme/theme_manager.dart';
import '../presentation/viewmodels/search_viewmodel.dart';
import '../../weather/presentation/viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchVM = Provider.of<SearchViewModel>(context);
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Locations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: WeatherBackgroundWidget(
        themeType: WeatherThemeType.night, // Dark backdrop for coordinates search
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // Glassmorphic Search Input Bar
                GlassContainer(
                  borderRadius: 16,
                  bgOpacity: 0.08,
                  borderOpacity: 0.12,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => searchVM.search(val),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            searchVM.clearSuggestions();
                          },
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Results or History lists
                Expanded(
                  child: searchVM.isSearching
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _searchController.text.isEmpty
                          ? _buildRecentAndFavorites(searchVM, weatherVM)
                          : _buildSuggestionsList(searchVM, weatherVM),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(SearchViewModel searchVM, WeatherViewModel weatherVM) {
    if (searchVM.searchError != null) {
      return Center(
        child: Text(
          searchVM.searchError!,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    final suggestions = searchVM.suggestions;
    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search for cities...',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final city = suggestions[index];
        return Card(
          color: Colors.white.withOpacity(0.04),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.location_on_rounded, color: Colors.white60),
            title: Text(city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.white60),
            onTap: () async {
              searchVM.addToHistory(city);
              
              // Add to global weather dashboard
              await weatherVM.addFavoriteCity(city.split(',').first);
              
              if (mounted) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentAndFavorites(SearchViewModel searchVM, WeatherViewModel weatherVM) {
    final recent = searchVM.recentSearches;
    final favs = weatherVM.favoriteCityNames;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorites Section
          if (favs.isNotEmpty) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Favorite Locations',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weatherVM.citiesWeatherList.length,
              itemBuilder: (context, index) {
                final isGps = index == 0;
                final cityWeather = weatherVM.citiesWeatherList[index];
                
                return Dismissible(
                  key: Key(cityWeather.cityName + index.toString()),
                  direction: isGps ? DismissDirection.none : DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await weatherVM.removeFavoriteCity(index);
                  },
                  child: Card(
                    color: Colors.white.withOpacity(0.04),
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Icon(
                        isGps ? Icons.gps_fixed_rounded : Icons.star_rounded,
                        color: isGps ? Colors.blue : Colors.amber,
                      ),
                      title: Text(
                        isGps ? '${cityWeather.cityName} (Current)' : cityWeather.cityName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        cityWeather.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      trailing: Text(
                        '${cityWeather.temp.toStringAsFixed(0)}°',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        weatherVM.setActiveCityIndex(index);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Recent Searches Section
          if (recent.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => searchVM.clearHistory(),
                  child: const Text('Clear All', style: TextStyle(color: Colors.white38)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recent.map((city) {
                return InputChip(
                  label: Text(city, style: const TextStyle(color: Colors.white70)),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () async {
                    // Tap to load instantly
                    await weatherVM.addFavoriteCity(city.split(',').first);
                    if (mounted) Navigator.pop(context);
                  },
                  onDeleted: () => searchVM.removeFromHistory(city),
                  deleteIconColor: Colors.white38,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
