import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/constants.dart';

const String weatherSyncTaskName = 'com.weatherx.app.sync_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    developer.log('Background Sync task started: $task');
    
    try {
      // 1. Init Hive inside isolation
      await Hive.initFlutter();
      final weatherBox = await Hive.openBox(AppConstants.weatherBoxName);
      final favoritesBox = await Hive.openBox(AppConstants.favoritesBoxName);
      final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);

      // Check settings to see if autoRefresh is enabled
      final autoRefresh = settingsBox.get('auto_refresh', defaultValue: true) as bool;
      if (!autoRefresh) {
        developer.log('Background sync disabled in settings. Aborting.');
        return true;
      }

      // 2. Fetch Favorites list
      final favListRaw = favoritesBox.get('list');
      if (favListRaw == null || favListRaw is! List || favListRaw.isEmpty) {
        developer.log('No favorites cities to sync.');
        return true;
      }

      final cities = List<String>.from(favListRaw);
      final apiKey = AppConstants.openWeatherApiKey;
      
      if (apiKey.isEmpty || apiKey == 'ENTER_API_KEY_HERE') {
        developer.log('API key not set for background worker. Aborting.');
        return true;
      }

      final dio = Dio();
      int successCount = 0;

      // 3. Loop and fetch new weather data
      for (final city in cities) {
        try {
          final response = await dio.get(
            '${AppConstants.apiBaseUrl}/weather',
            queryParameters: {
              'q': city,
              'units': 'metric',
              'appid': apiKey,
            },
          );

          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>;
            final cacheKey = 'weather_${city.toLowerCase()}';
            
            // Map basics to cache (simplified structure or raw mapped entity)
            final coord = data['coord'] as Map<String, dynamic>? ?? {};
            final main = data['main'] as Map<String, dynamic>? ?? {};
            final sys = data['sys'] as Map<String, dynamic>? ?? {};
            final wind = data['wind'] as Map<String, dynamic>? ?? {};
            final clouds = data['clouds'] as Map<String, dynamic>? ?? {};
            final weatherList = data['weather'] as List? ?? [];
            final weather = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};

            final tempVal = (main['temp'] as num?)?.toDouble() ?? 0.0;
            final humidityVal = main['humidity'] as int? ?? 0;

            final jsonMap = {
              'cityName': data['name'] as String? ?? city,
              'latitude': (coord['lat'] as num?)?.toDouble() ?? 0.0,
              'longitude': (coord['lon'] as num?)?.toDouble() ?? 0.0,
              'temp': tempVal,
              'feelsLike': (main['feels_like'] as num?)?.toDouble() ?? tempVal,
              'tempMin': (main['temp_min'] as num?)?.toDouble() ?? tempVal,
              'tempMax': (main['temp_max'] as num?)?.toDouble() ?? tempVal,
              'condition': weather['main'] as String? ?? 'Clear',
              'description': weather['description'] as String? ?? 'clear sky',
              'iconCode': weather['icon'] as String? ?? '01d',
              'humidity': humidityVal,
              'pressure': main['pressure'] as int? ?? 1013,
              'windSpeed': (wind['speed'] as num?)?.toDouble() ?? 0.0,
              'windDirection': wind['deg'] as int? ?? 0,
              'visibility': (data['visibility'] as num?)?.toDouble() ?? 10000.0,
              'cloudCover': clouds['all'] as int? ?? 0,
              'dewPoint': double.parse((tempVal - ((100 - humidityVal) / 5)).toStringAsFixed(1)),
              'rainProbability': data['rain'] != null ? 0.8 : 0.05,
              'uvIndex': 5.0,
              'sunrise': sys['sunrise'] as int? ?? 0,
              'sunset': sys['sunset'] as int? ?? 0,
              'timestamp': data['dt'] as int? ?? 0,
            };

            await weatherBox.put(cacheKey, jsonEncode(jsonMap));
            successCount++;
          }
        } catch (e) {
          developer.log('Background fetch error for $city: $e');
        }
      }

      // 4. Trigger localized notification if updates were successful
      if (successCount > 0) {
        final localNotifications = FlutterLocalNotificationsPlugin();
        const androidDetails = AndroidNotificationDetails(
          'weather_sync_channel',
          'Weather Sync',
          channelDescription: 'Reports background weather cache sync updates',
          importance: Importance.low,
          priority: Priority.low,
        );
        const iosDetails = DarwinNotificationDetails();
        const platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

        await localNotifications.show(
          999,
          'Weather cache updated',
          'Successfully synced weather data for $successCount locations.',
          platformDetails,
        );
      }
      
      developer.log('Background sync complete. Successful: $successCount');
      return true;
    } catch (e) {
      developer.log('Background Sync task crashed: $e');
      return false;
    }
  });
}
