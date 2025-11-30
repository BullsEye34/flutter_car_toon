import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon_example/examples/models/address.dart';
import 'package:flutter_car_toon_example/examples/models/profile.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  group('Nested Object Tests', () {
    test('Address toToon() generates correct map', () {
      final address = Address(
        street: '123 Main St',
        city: 'New York',
        country: 'USA',
        zipCode: 10001,
      );

      final toonMap = address.toToon();

      expect(toonMap['street'], '123 Main St');
      expect(toonMap['city'], 'New York');
      expect(toonMap['country'], 'USA');
      expect(toonMap['zipCode'], 10001);
    });

    test('Profile with nested Address serializes correctly', () {
      final address = Address(
        street: '456 Elm St',
        city: 'Los Angeles',
        country: 'USA',
        zipCode: 90001,
      );

      final profile = Profile(username: 'john_doe', address: address);

      final toonMap = profile.toToon();

      expect(toonMap['username'], 'john_doe');
      expect(toonMap['address'], isA<Map<String, dynamic>>());

      final addressMap = toonMap['address'] as Map<String, dynamic>;
      expect(addressMap['street'], '456 Elm St');
      expect(addressMap['city'], 'Los Angeles');
    });

    test('Profile with list of addresses serializes correctly', () {
      final address1 = Address(
        street: '123 First St',
        city: 'Chicago',
        zipCode: 60601,
      );

      final address2 = Address(
        street: '789 Second Ave',
        city: 'Seattle',
        zipCode: 98101,
      );

      final profile = Profile(
        username: 'jane_doe',
        address: address1,
        previousAddresses: [address1, address2],
      );

      final toonMap = profile.toToon();

      expect(toonMap['previousAddresses'], isA<List>());
      final previousList = toonMap['previousAddresses'] as List;
      expect(previousList.length, 2);
      expect(previousList[0], isA<Map<String, dynamic>>());
      expect((previousList[0] as Map)['street'], '123 First St');
      expect((previousList[1] as Map)['street'], '789 Second Ave');
    });

    test('Profile fromToon() reconstructs nested objects', () {
      final toonMap = {
        'username': 'test_user',
        'address': {
          'street': '999 Test Rd',
          'city': 'TestCity',
          'country': 'TestCountry',
          'zipCode': 99999,
        },
        'previousAddresses': null,
      };

      final profile = $ProfileFromToon(toonMap);

      expect(profile.username, 'test_user');
      expect(profile.address.street, '999 Test Rd');
      expect(profile.address.city, 'TestCity');
      expect(profile.address.country, 'TestCountry');
      expect(profile.address.zipCode, 99999);
      expect(profile.previousAddresses, null);
    });

    test('Profile with list fromToon() reconstructs correctly', () {
      final toonMap = {
        'username': 'multi_address',
        'address': {
          'street': 'Current St',
          'city': 'CurrentCity',
          'country': null,
          'zipCode': 11111,
        },
        'previousAddresses': [
          {
            'street': 'Old St 1',
            'city': 'OldCity1',
            'country': 'Country1',
            'zipCode': 22222,
          },
          {
            'street': 'Old St 2',
            'city': 'OldCity2',
            'country': null,
            'zipCode': 33333,
          },
        ],
      };

      final profile = $ProfileFromToon(toonMap);

      expect(profile.username, 'multi_address');
      expect(profile.address.street, 'Current St');
      expect(profile.previousAddresses?.length, 2);
      expect(profile.previousAddresses![0].street, 'Old St 1');
      expect(profile.previousAddresses![0].city, 'OldCity1');
      expect(profile.previousAddresses![1].street, 'Old St 2');
      expect(profile.previousAddresses![1].country, null);
    });

    test('Nested round-trip serialization preserves data', () {
      final address = Address(
        street: 'Round Trip St',
        city: 'RoundTripCity',
        country: 'RTC',
        zipCode: 12345,
      );

      final profile = Profile(
        username: 'roundtrip_user',
        address: address,
        previousAddresses: [
          Address(street: 'Prev1', city: 'City1', zipCode: 11111),
          Address(
            street: 'Prev2',
            city: 'City2',
            country: 'C2',
            zipCode: 22222,
          ),
        ],
      );

      // Serialize to map
      final toonMap = profile.toToon();

      // Deserialize back
      final reconstructed = $ProfileFromToon(toonMap);

      expect(reconstructed.username, profile.username);
      expect(reconstructed.address.street, profile.address.street);
      expect(reconstructed.address.city, profile.address.city);
      expect(
        reconstructed.previousAddresses?.length,
        profile.previousAddresses?.length,
      );
      expect(
        reconstructed.previousAddresses![0].street,
        profile.previousAddresses![0].street,
      );
      expect(
        reconstructed.previousAddresses![1].country,
        profile.previousAddresses![1].country,
      );
    });

    test('Integration with TOON encoder for nested objects', () {
      final profile = Profile(
        username: 'toon_test',
        address: Address(
          street: '777 TOON Blvd',
          city: 'TOONville',
          zipCode: 77777,
        ),
      );

      // Serialize to map
      final toonMap = profile.toToon();

      // Encode to TOON string format
      final toonString = toon.encode(toonMap);

      expect(toonString, contains('username: toon_test'));
      expect(toonString, contains('address:'));
      expect(toonString, contains('street: 777 TOON Blvd'));

      // Decode back from TOON string
      final decoded = toon.decode(toonString) as Map<String, dynamic>;

      // Reconstruct object
      final reconstructed = $ProfileFromToon(decoded);

      expect(reconstructed.username, profile.username);
      expect(reconstructed.address.street, profile.address.street);
      expect(reconstructed.address.city, profile.address.city);
    });
  });
}
