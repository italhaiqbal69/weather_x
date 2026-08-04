import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';
import 'app/dependency_injection.dart';
import 'core/services/background_worker.dart';

void main() async {
  // Ensure Flutter engine integrations are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection container and local services (Hive, storage, theme)
  await initDI();

  // Initialize Workmanager for periodic background sync
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register 15-minute background sync interval (minimum allowed by Android/iOS platforms)
    await Workmanager().registerPeriodicTask(
      'weather_sync_periodic',
      weatherSyncTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  } catch (e) {
    // Fail-safe print in case running on platforms with no Workmanager support
    debugPrint('Workmanager initialization skipped: $e');
  }

  // Launch app
  runApp(const WeatherXApp());
}
