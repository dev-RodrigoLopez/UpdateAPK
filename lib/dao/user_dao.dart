import 'package:floor/floor.dart';
import 'package:update_apk/models/user_model.dart';


@dao
abstract class UserDao {

  @Query('SELECT * FROM users')
  Future<List<User>> getAllUsers();

  @Query('SELECT * FROM users WHERE id = :id')
  Future<User?> findUserById(int id);

  @insert
  Future<int> insertUser(User user);

  @update
  Future<void> updateUser(User user);

  @delete
  Future<void> deleteUser(User user);
}
