import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../core/api/api_client.dart';
import '../core/network/network_info.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/storage/hive_storage.dart';
import '../core/theme/theme_manager.dart';
import '../features/weather/data/repository/weather_repository_impl.dart';
import '../features/weather/domain/repositories/weather_repository.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Core Services & Helpers
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  final hiveStorage = HiveStorageImpl();
  sl.registerSingleton<HiveStorage>(hiveStorage);
  await hiveStorage.init();

  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());

  final notificationService = NotificationServiceImpl();
  sl.registerSingleton<NotificationService>(notificationService);
  await notificationService.init();

  // Theme
  sl.registerSingleton<ThemeManager>(ThemeManager());

  // Network client
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Repositories
  sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(
        apiClient: sl(),
        hiveStorage: sl(),
        networkInfo: sl(),
      ));
}
