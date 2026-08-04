class AppConstants {
  // OpenWeather API Config
  // We provide a fallback mock state if the API key is empty or invalid.
  static const String openWeatherApiKey = '7d9040cbef459176d1f2a53d09523266'; // ENTER_API_KEY_HERE
  static const String apiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoBaseUrl = 'https://api.openweathermap.org/geo/1.0';
  static const String mapTileUrl = 'https://tile.openweathermap.org/map';

  static const String osrmRouteUrl = 'https://router.project-osrm.org/route/v1/driving';

  // Hive Box Names
  static const String weatherBoxName = 'weather_box';
  static const String settingsBoxName = 'settings_box';
  static const String favoritesBoxName = 'favorites_box';
  static const String realFeelVotesBoxName = 'realfeel_votes_box'; // For storing RealFeel votes

  // Shared Preferences Keys
  static const String keyFirstTime = 'is_first_time';
  static const String keyTempUnit = 'temp_unit';
  static const String keyWindUnit = 'wind_unit';
  static const String keyPressureUnit = 'pressure_unit';
  static const String keyThemeMode = 'theme_mode';
  static const String keyGeminiApiKey = 'gemini_api_key';

  // Animation assets (Lottie and Svg placeholders)
  static const String animSplash = 'assets/animations/weather_splash.json';
  static const String animSunny = 'assets/animations/sunny.json';
  static const String animCloudy = 'assets/animations/cloudy.json';
  static const String animRainy = 'assets/animations/rainy.json';
  static const String animStormy = 'assets/animations/stormy.json';
  static const String animSnowy = 'assets/animations/snowy.json';
  static const String animFoggy = 'assets/animations/foggy.json';
  static const String animNight = 'assets/animations/night_clear.json';
}
