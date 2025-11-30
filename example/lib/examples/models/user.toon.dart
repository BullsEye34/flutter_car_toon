// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// ToonGenerator
// **************************************************************************

extension UserToonExtension on User {
  /// Convert this object to TOON map format
  Map<String, dynamic> toToon() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'isActive': isActive,
      'tags_list': tags,
      if (bio != null) 'bio': bio,
    };
  }
}

/// Helper function to create User from TOON map
User $UserFromToon(Map<String, dynamic> toon) {
  return User(
    name: toon['name'] as String,
    age: toon['age'] as int,
    email: toon['email'] as String,
    isActive: toon['isActive'] as bool,
    tags: toon['tags_list'] == null
        ? null
        : (toon['tags_list'] as List).cast<String>(),
    bio: toon['bio'] as String?,
  );
}
