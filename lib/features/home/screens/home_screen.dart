import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_x/core/storage/hive_storage.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/weather_background_widget.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../search/screens/search_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../weather/presentation/viewmodels/weather_viewmodel.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/presentation/widgets/lifestyle_suggestions_widget.dart';
import '../../weather_details/widgets/weather_details_grid.dart';
import '../../forecast/widgets/hourly_forecast_widget.dart';
import '../../forecast/widgets/daily_forecast_widget.dart';
import '../../air_quality/widgets/air_quality_widget.dart';
import '../../astronomy/widgets/astronomy_widget.dart';
import '../../maps/screens/weather_map_screen.dart';
import '../../travel/screens/route_weather_screen.dart';
import '../../weather/presentation/widgets/ai_coach_widget.dart';
import '../../weather/presentation/widgets/realfeel_vote_widget.dart';
import '../../weather/presentation/widgets/gardening_widget.dart';
import '../../astronomy/widgets/scenic_shot_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final weatherVM = Provider.of<WeatherViewModel>(context, listen: false);
    _pageController = PageController(initialPage: weatherVM.activeCityIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherVM = Provider.of<WeatherViewModel>(context);
    final settingsVM = Provider.of<SettingsViewModel>(context);
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      body: WeatherBackgroundWidget(
        themeType: themeManager.currentThemeType,
        child: SafeArea(
          bottom: false,
          child: _buildBody(weatherVM, settingsVM),
        ),
      ),
    );
  }

  Widget _buildBody(WeatherViewModel weatherVM, SettingsViewModel settingsVM) {
    if (weatherVM.isLoading && weatherVM.citiesWeatherList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (weatherVM.isError && weatherVM.citiesWeatherList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white60,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                weatherVM.errorMessage ?? 'An error occurred fetching weather.',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    weatherVM.loadAllWeatherData(forceRefresh: true),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    if (weatherVM.citiesWeatherList.isEmpty) {
      return const Center(
        child: Text(
          'No location details loaded.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        // Premium Custom Top Navigation Bar
        _buildTopBar(weatherVM),

        // Multi-city swiper panel
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: weatherVM.citiesWeatherList.length,
            onPageChanged: (index) {
              weatherVM.setActiveCityIndex(index);
            },
            itemBuilder: (context, index) {
              final weather = weatherVM.citiesWeatherList[index];
              return _buildWeatherContent(weather, weatherVM, settingsVM);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(WeatherViewModel weatherVM) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings button
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          // Swipe Dots / Title indicators
          Row(
            children: List.generate(weatherVM.citiesWeatherList.length, (idx) {
              final isGps = idx == 0;
              final isActive = weatherVM.activeCityIndex == idx;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                width: isActive ? 12.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white38,
                  shape: isGps && !isActive
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: isGps && !isActive
                      ? BorderRadius.circular(1)
                      : null,
                ),
              );
            }),
          ),

          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RouteWeatherScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(
    WeatherEntity weather,
    WeatherViewModel weatherVM,
    SettingsViewModel settingsVM,
  ) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);
    final formattedTime = DateFormat('jm').format(now);

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () => weatherVM.refreshActiveCity(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 1. Current Weather Primary Info
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (weatherVM.activeCityIndex == 0)
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        weather.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate • $formattedTime',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Temperature displays
                  Text(
                    settingsVM.formatTemperature(weather.temp),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 88,
                      fontWeight: FontWeight.w200,
                      height: 0.9,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    weather.description.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Low / High
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'H: ${settingsVM.formatTemperature(weather.tempMax)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'L: ${settingsVM.formatTemperature(weather.tempMin)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick access Radar Map Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                icon: const Icon(Icons.map_rounded, color: Colors.blueAccent),
                label: const Text(
                  'Open Interactive Radar Map',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeatherMapScreen(
                        initialLat: weather.latitude,
                        initialLon: weather.longitude,
                        cityName: weather.cityName,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 2. Hourly Forecast Widget
            if (weatherVM.forecast != null)
              HourlyForecastWidget(
                hourlyList: weatherVM.forecast!.hourly,
                settingsVM: settingsVM,
              ),

            const SizedBox(height: 16),

            // 2.5 AI Weather Coach
            AiCoachWidget(
              weather: weather,
              geminiApiKey: settingsVM.geminiApiKey,
            ),

            const SizedBox(height: 16),

            // 3. Air Quality gauge
            if (weatherVM.airQuality != null)
              AirQualityWidget(airQuality: weatherVM.airQuality!),

            const SizedBox(height: 16),

            // 3.5 Gardening & Comfort Advisor
            GardeningWidget(weather: weather),

            const SizedBox(height: 16),

            // 3.6 RealFeel Calibration
            RealFeelVoteWidget(
              cityName: weather.cityName,
              hiveStorage: sl<HiveStorage>(),
            ),

            const SizedBox(height: 16),

            // 4. Expandable Daily Forecast
            if (weatherVM.forecast != null)
              DailyForecastWidget(
                dailyList: weatherVM.forecast!.daily,
                settingsVM: settingsVM,
              ),

            const SizedBox(height: 16),

            // 5. Astronomy panel
            if (weatherVM.astronomy != null) ...[
              AstronomyWidget(astronomy: weatherVM.astronomy!),
              const SizedBox(height: 16),
              ScenicShotWidget(
                weather: weather,
                astronomy: weatherVM.astronomy!,
              ),
            ],

            const SizedBox(height: 16),

            // 6. Lifestyle recommendations
            LifestyleSuggestionsWidget(weather: weather),

            const SizedBox(height: 20),

            // 7. Metrics details grid
            WeatherDetailsGrid(weather: weather, settingsVM: settingsVM),
          ],
        ),
      ),
    );
  }
}
