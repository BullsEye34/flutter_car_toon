import 'package:flutter_car_toon/flutter_car_toon.dart';
import 'models/user.dart';
import 'person.dart';

void testGeneratedCode() {
  // Test User with all features
  final user = User(
    name: 'Alice',
    age: 30,
    email: 'alice@example.com',
    isActive: true,
    tags: ['admin', 'developer'],
    bio: 'Software engineer',
  );

  // Test toToon method
  final userToon = user.toToon();

  // Test fromToon factory
  final userFromToon = $UserFromToon(userToon);
  assert(userFromToon.name == user.name);
  assert(userFromToon.age == user.age);

  // Test Person (simpler case)
  final person = Person(name: 'Bob', age: 25, email: 'bob@example.com');

  final personToon = person.toToon();

  final personFromToon = $PersonFromToon(personToon);
  assert(personFromToon.name == person.name);
  assert(personFromToon.age == person.age);

  // Test with null values
  final userWithoutBio = User(
    name: 'Charlie',
    age: 35,
    email: 'charlie@example.com',
  );

  final userWithoutBioToon = userWithoutBio.toToon();
  // Bio should not be in map
  assert(!userWithoutBioToon.containsKey('bio'));

  // Test encoding to TOON format
  final toonEncoded = toon.encode(userToon);

  // Test decoding from TOON format
  final toonDecoded = toon.decode(toonEncoded);

  // Recreate user from decoded TOON
  final userFromToonString = $UserFromToon(toonDecoded as Map<String, dynamic>);
  // Verify data integrity
  assert(userFromToonString.name == user.name);
  assert(userFromToonString.age == user.age);
}
