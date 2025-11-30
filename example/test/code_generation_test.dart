import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon_example/examples/models/user.dart';
import 'package:flutter_car_toon_example/examples/person.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  group('Code Generation Tests', () {
    test('toToon() generates correct map', () {
      final user = User(
        name: 'Alice',
        age: 30,
        email: 'alice@example.com',
        isActive: true,
        tags: ['admin', 'developer'],
        bio: 'Software engineer',
      );

      final toonMap = user.toToon();

      expect(toonMap['name'], 'Alice');
      expect(toonMap['age'], 30);
      expect(toonMap['email'], 'alice@example.com');
      expect(toonMap['isActive'], true);
      expect(toonMap['tags_list'], ['admin', 'developer']);
      expect(toonMap['bio'], 'Software engineer');
    });

    test('toToon() excludes null bio when includeIfNull is false', () {
      final user = User(
        name: 'Bob',
        age: 25,
        email: 'bob@example.com',
        tags: null,
        bio: null,
      );

      final toonMap = user.toToon();

      expect(toonMap.containsKey('bio'), false);
      expect(
        toonMap.containsKey('tags_list'),
        true,
      ); // tags has includeIfNull true by default
    });

    test('fromToon() reconstructs object correctly', () {
      final toonMap = {
        'name': 'Charlie',
        'age': 35,
        'email': 'charlie@example.com',
        'isActive': false,
        'tags_list': ['user'],
        'bio': 'Test bio',
      };

      final user = $UserFromToon(toonMap);

      expect(user.name, 'Charlie');
      expect(user.age, 35);
      expect(user.email, 'charlie@example.com');
      expect(user.isActive, false);
      expect(user.tags, ['user']);
      expect(user.bio, 'Test bio');
    });

    test('fromToon() handles null values', () {
      final toonMap = {
        'name': 'Dave',
        'age': 40,
        'email': 'dave@example.com',
        'isActive': true,
        'tags_list': null,
        'bio': null,
      };

      final user = $UserFromToon(toonMap);

      expect(user.name, 'Dave');
      expect(user.tags, null);
      expect(user.bio, null);
    });

    test('Round-trip serialization preserves data', () {
      final original = User(
        name: 'Eve',
        age: 28,
        email: 'eve@example.com',
        isActive: true,
        tags: ['tester', 'qa'],
        bio: 'Quality assurance specialist',
      );

      final toonMap = original.toToon();
      final reconstructed = $UserFromToon(toonMap);

      expect(reconstructed.name, original.name);
      expect(reconstructed.age, original.age);
      expect(reconstructed.email, original.email);
      expect(reconstructed.isActive, original.isActive);
      expect(reconstructed.tags, original.tags);
      expect(reconstructed.bio, original.bio);
    });

    test('Integration with TOON encoder/decoder', () {
      final user = User(
        name: 'Frank',
        age: 45,
        email: 'frank@example.com',
        isActive: true,
        tags: ['admin', 'superuser'],
        bio: 'System administrator',
      );

      // Convert to map
      final toonMap = user.toToon();

      // Encode to TOON format
      final toonString = toon.encode(toonMap);

      // Verify it's a valid TOON string
      expect(toonString, contains('name: Frank'));
      expect(toonString, contains('age: 45'));

      // Decode back
      final decoded = toon.decode(toonString) as Map<String, dynamic>;

      // Reconstruct object
      final reconstructed = $UserFromToon(decoded);

      expect(reconstructed.name, user.name);
      expect(reconstructed.age, user.age);
      expect(reconstructed.email, user.email);
    });

    test('Person class with nullable field', () {
      final person = Person(name: 'George', age: 50, email: null);

      final toonMap = person.toToon();
      expect(toonMap['name'], 'George');
      expect(toonMap['age'], 50);
      expect(toonMap['email'], null);

      final reconstructed = $PersonFromToon(toonMap);
      expect(reconstructed.name, person.name);
      expect(reconstructed.age, person.age);
      expect(reconstructed.email, null);
    });

    test('@ToonField name customization', () {
      final user = User(
        name: 'Hannah',
        age: 32,
        email: 'hannah@example.com',
        tags: ['developer'],
      );

      final toonMap = user.toToon();

      // tags should be serialized as 'tags_list'
      expect(toonMap.containsKey('tags_list'), true);
      expect(toonMap.containsKey('tags'), false);
      expect(toonMap['tags_list'], ['developer']);
    });
  });
}
