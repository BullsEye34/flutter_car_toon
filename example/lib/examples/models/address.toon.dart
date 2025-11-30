// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'address.dart';

// **************************************************************************
// ToonGenerator
// **************************************************************************

extension AddressToonExtension on Address {
  /// Convert this object to TOON map format
  Map<String, dynamic> toToon() {
    return {
      'street': street,
      'city': city,
      'country': country,
      'zipCode': zipCode,
    };
  }
}

/// Helper function to create Address from TOON map
Address $AddressFromToon(Map<String, dynamic> toon) {
  return Address(
    street: toon['street'] as String,
    city: toon['city'] as String,
    country: toon['country'] as String?,
    zipCode: toon['zipCode'] as int,
  );
}
