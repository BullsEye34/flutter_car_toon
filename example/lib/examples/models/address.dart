import 'package:flutter_car_toon/flutter_car_toon.dart';

part 'address.toon.dart';

/// Example address model for testing nested serialization
@ToonSerializable()
class Address {
  final String street;
  final String city;
  final String? country;
  final int zipCode;

  const Address({
    required this.street,
    required this.city,
    this.country,
    required this.zipCode,
  });
}
