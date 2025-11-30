import 'package:flutter_car_toon/flutter_car_toon.dart';

part 'user.toon.dart';

/// Example user model with code generation
@ToonSerializable()
class User {
  final String name;
  final int age;
  final String email;
  final bool isActive;

  @ToonField(name: 'tags_list')
  final List<String>? tags;

  @ToonField(includeIfNull: false)
  final String? bio;

  const User({
    required this.name,
    required this.age,
    required this.email,
    this.isActive = true,
    this.tags,
    this.bio,
  });
}
