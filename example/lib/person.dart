import 'package:flutter_car_toon/flutter_car_toon.dart';

part 'person.toon.dart';

@ToonSerializable()
class Person {
  Person({required this.name, required this.age, this.email});

  final String name;
  final int age;
  final String? email;
}
