import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:update_apk/dao/user_dao.dart';
import 'package:update_apk/models/user_model.dart';



part 'app_database.g.dart'; // Auto-generado

@Database(
  version: 1, 
  entities: [
    User
  ]
)
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}
