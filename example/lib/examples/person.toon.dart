// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// ToonGenerator
// **************************************************************************

extension PersonToonExtension on Person {
  /// Convert this object to TOON map format
  Map<String, dynamic> toToon() {
    return {
      'name': name,
      'age': age,
      'email': email,
    };
  }
}

/// Helper function to create Person from TOON map
Person $PersonFromToon(Map<String, dynamic> toon) {
  return Person(
    name: toon['name'] as String,
    age: toon['age'] as int,
    email: toon['email'] as String?,
  );
}
