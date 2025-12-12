import 'package:update_apk/data/app_database.dart';

class DatabaseInstance {
  static AppDatabase? _instance;

  DatabaseInstance._();

  static Future<AppDatabase> get instance async {
    if (_instance != null) return _instance!;

    _instance = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();

    return _instance!;
  }
}
