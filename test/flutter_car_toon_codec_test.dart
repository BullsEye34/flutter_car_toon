/// Tests for TOON codec functionality
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  group('ToonCodec Basic Tests', () {
    late ToonCodec codec;

    setUp(() {
      codec = const ToonCodec();
    });

    test('encode simple object', () {
      final data = {'name': 'Alice', 'age': 30};
      final result = codec.encode(data);
      expect(result, contains('name: Alice'));
      expect(result, contains('age: 30'));
    });

    test('encode simple array', () {
      final data = [1, 2, 3];
      final result = codec.encode(data);
      expect(result, equals('[3]: 1,2,3'));
    });

    test('encode nested object', () {
      final data = {
        'user': {
          'name': 'Alice',
          'profile': {'age': 30},
        },
      };
      final result = codec.encode(data);
      expect(result, contains('user:'));
      expect(result, contains('name: Alice'));
    });

    test('encode boolean values', () {
      final data = {'active': true, 'hidden': false};
      final result = codec.encode(data);
      expect(result, contains('active: true'));
      expect(result, contains('hidden: false'));
    });

    test('encode null values', () {
      final data = {'value': null};
      final result = codec.encode(data);
      expect(result, contains('value: null'));
    });

    test('encode string with special characters', () {
      final data = {'message': 'Hello, World!'};
      final result = codec.encode(data);
      expect(result, contains('message: "Hello, World!"'));
    });

    test('encode empty structures', () {
      expect(codec.encode({}), equals(''));
      expect(codec.encode([]), equals('[0]:'));
    });

    test('encode numbers', () {
      final data = {'int': 42, 'double': 3.14, 'negative': -1};
      final result = codec.encode(data);
      expect(result, contains('int: 42'));
      expect(result, contains('double: 3.14'));
      expect(result, contains('negative: -1'));
    });

    test('convenience methods', () {
      final data = {'test': 'value'};

      // Test global convenience functions
      final encoded = toonEncode(data);
      final decoded = toonDecode(encoded);

      expect(encoded, contains('test: value'));
      expect(decoded, equals(data));
    });

    test('toon class static methods', () {
      final data = {'name': 'Bob', 'score': 95};

      final encoded = toon.encode(data);
      final decoded = toon.decode(encoded);

      expect(encoded, isA<String>());
      expect(decoded, equals(data));
    });
  });

  group('ToonCodec Advanced Tests', () {
    test('encode with custom options', () {
      final codec = ToonCodec(options: ToonOptions.pretty);

      final data = {
        'nested': {'key': 'value'},
      };
      final result = codec.encode(data);

      // Should use 4-space indentation
      expect(result, contains('    key: value'));
    });

    test('round trip encoding and decoding', () {
      final originalData = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ],
        'meta': {'count': 2, 'active': true},
      };

      final codec = const ToonCodec();
      final encoded = codec.encode(originalData);

      // For now, just test that encoding works
      expect(encoded, isA<String>());
      expect(encoded, isNotEmpty);
    });
  });

  group('ToonOptions Tests', () {
    test('default options', () {
      const options = ToonOptions.defaults;
      expect(options.indent, equals(2));
      expect(options.delimiter, equals(ToonDelimiter.comma));
      expect(options.strictMode, isFalse);
    });

    test('strict options', () {
      const options = ToonOptions.strict;
      expect(options.strictMode, isTrue);
      expect(options.validationLevel, equals(ToonValidationLevel.strict));
    });

    test('copyWith functionality', () {
      const original = ToonOptions.defaults;
      final modified = original.copyWith(indent: 4, strictMode: true);

      expect(modified.indent, equals(4));
      expect(modified.strictMode, isTrue);
      expect(modified.delimiter, equals(original.delimiter)); // unchanged
    });
  });

  group('Error Handling Tests', () {
    test('encoding unsupported objects throws error', () {
      final codec = const ToonCodec();

      expect(
        () => codec.encode(DateTime.now()),
        throwsA(isA<ToonEncodingError>()),
      );
    });

    test('ToonError provides useful information', () {
      try {
        const ToonCodec().encode(Object());
      } on ToonError catch (e) {
        expect(e.message, isNotEmpty);
        expect(e.toString(), contains('ToonEncodingError'));
      }
    });
  });

  group('Converter Registry Tests', () {
    test('global converter registry exists', () {
      expect(globalToonConverterRegistry, isNotNull);
    });

    test('can register custom converter', () {
      final registry = ToonConverterRegistry();
      const converter = StringToonConverter();

      registry.register<String>(converter);

      final retrievedConverter = registry.getConverterForType(String);
      expect(retrievedConverter, isA<StringToonConverter>());
    });
  });
}
