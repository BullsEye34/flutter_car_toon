// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// ToonGenerator
// **************************************************************************

extension ProfileToonExtension on Profile {
  /// Convert this object to TOON map format
  Map<String, dynamic> toToon() {
    return {
      'username': username,
      'address': address.toToon(),
      'previousAddresses': previousAddresses?.map((e) => e.toToon()).toList(),
    };
  }
}

/// Helper function to create Profile from TOON map
Profile $ProfileFromToon(Map<String, dynamic> toon) {
  return Profile(
    username: toon['username'] as String,
    address: $AddressFromToon(toon['address'] as Map<String, dynamic>),
    previousAddresses: toon['previousAddresses'] == null
        ? null
        : (toon['previousAddresses'] as List)
            .map((e) => $AddressFromToon(e as Map<String, dynamic>))
            .toList(),
  );
}
