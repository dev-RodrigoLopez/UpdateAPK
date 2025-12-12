import 'package:floor/floor.dart';

@Entity(tableName: 'users')
class User {
  @primaryKey
  final int id;

  final String name;
  final int age;

  User(this.id, this.name, this.age);
}
