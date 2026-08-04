import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dependency_injection.dart';
import '../core/theme/theme_manager.dart';
import '../features/search/presentation/viewmodels/search_viewmodel.dart';
import '../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/weather/presentation/viewmodels/weather_viewmodel.dart';

class WeatherXApp extends StatelessWidget {
  const WeatherXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>(
          create: (_) => sl<ThemeManager>(),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(hiveStorage: sl()),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            repository: sl(),
            locationService: sl(),
            hiveStorage: sl(),
          ),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            repository: sl(),
            hiveStorage: sl(),
          ),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'WeatherX',
            debugShowCheckedModeBanner: false,
            theme: themeManager.currentThemeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
