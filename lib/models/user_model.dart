import 'package:floor/floor.dart';

@Entity(tableName: 'users')
class User {
  
  User({
    this.id,
    required this.name, 
    required this.age
  });


  @PrimaryKey( autoGenerate: true )
  int? id;
  String name;
  int age;

}
