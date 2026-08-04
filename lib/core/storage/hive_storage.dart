import 'package:hive_flutter/hive_flutter.dart';
import '../constants/constants.dart';

abstract class HiveStorage {
  Future<void> init();
  Future<void> save(String boxName, String key, dynamic value);
  dynamic get(String boxName, String key, {dynamic defaultValue});
  Future<void> delete(String boxName, String key);
  Future<void> clear(String boxName);
}

class HiveStorageImpl implements HiveStorage {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Open the primary boxes
    await Hive.openBox(AppConstants.weatherBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    await Hive.openBox(AppConstants.favoritesBoxName);
    await Hive.openBox(AppConstants.realFeelVotesBoxName);
  }

  @override
  Future<void> save(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  @override
  dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}
