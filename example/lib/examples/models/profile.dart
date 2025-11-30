import 'package:flutter_car_toon/flutter_car_toon.dart';
import 'address.dart';

part 'profile.toon.dart';

/// Example profile model with nested Address
@ToonSerializable()
class Profile {
  final String username;
  final Address address;
  final List<Address>? previousAddresses;

  const Profile({
    required this.username,
    required this.address,
    this.previousAddresses,
  });
}
