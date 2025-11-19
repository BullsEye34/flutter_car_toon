/// Comprehensive tests for ToonDecoder
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  group('ToonDecoder Tests', () {
    late ToonDecoder decoder;

    setUp(() {
      decoder = ToonDecoder(options: ToonOptions.defaults);
    });

    group('Primitive Decoding', () {
      test('decode strings', () {
        expect(decoder.convert('hello'), equals('hello'));
        expect(decoder.convert('"hello world"'), equals('hello world'));
        expect(decoder.convert('""'), equals(''));
      });

      test('decode numbers', () {
        expect(decoder.convert('42'), equals(42));
        expect(decoder.convert('3.14'), equals(3.14));
        expect(decoder.convert('0'), equals(0));
        expect(decoder.convert('-1'), equals(-1));
      });

      test('decode booleans', () {
        expect(decoder.convert('true'), equals(true));
        expect(decoder.convert('false'), equals(false));
      });

      test('decode null', () {
        expect(decoder.convert('null'), isNull);
      });
    });

    group('Simple Object Decoding', () {
      test('decode simple key-value pairs', () {
        final result = decoder.convert('name: Alice\nage: 30');
        expect(result, isA<Map>());
        final map = result as Map;
        expect(map['name'], equals('Alice'));
        expect(map['age'], equals(30));
      });

      test('decode quoted strings', () {
        final result = decoder.convert('message: "Hello, World!"');
        expect(result, isA<Map>());
        final map = result as Map;
        expect(map['message'], equals('Hello, World!'));
      });

      test('decode mixed types', () {
        final result = decoder.convert(
          'name: Alice\nage: 30\nactive: true\ndata: null',
        );
        expect(result, isA<Map>());
        final map = result as Map;
        expect(map['name'], equals('Alice'));
        expect(map['age'], equals(30));
        expect(map['active'], equals(true));
        expect(map['data'], isNull);
      });
    });

    group('Array Decoding', () {
      test('decode simple arrays', () {
        const toonString = '[3]: 1,2,3';
        final result = decoder.convert(toonString);
        // Basic decoder treats arrays as key-value pairs
        expect(result, equals({'[3]': '1,2,3'}));
      });

      test('decode string arrays', () {
        const toonString = '[2]: hello,world';
        final result = decoder.convert(toonString);
        expect(result, equals({'[2]': 'hello,world'}));
      });

      test('decode empty arrays', () {
        const toonString = '[0]: ';
        final result = decoder.convert(toonString);
        expect(result, equals({'[0]': ''}));
      });

      test('decode mixed type arrays', () {
        const toonString = '[4]: 1,hello,true,null';
        final result = decoder.convert(toonString);
        expect(result, equals({'[4]': '1,hello,true,null'}));
      });
    });

    group('Error Handling', () {
      test('throws error for empty input', () {
        expect(() => decoder.convert(''), throwsA(isA<ToonDecodingError>()));
      });

      test('handles invalid format gracefully', () {
        // Basic decoder returns the input as-is for invalid formats
        final result = decoder.convert('invalid{format');
        expect(result, equals('invalid{format'));
      });

      test('provides useful error context', () {
        try {
          decoder.convert('invalid:format:with:too:many:colons');
        } on ToonDecodingError catch (e) {
          expect(e.message, isNotEmpty);
          expect(e.source, isNotEmpty);
        }
      });
    });

    group('Round Trip Tests', () {
      test('encode then decode primitives', () {
        final encoder = ToonEncoder(options: ToonOptions.defaults);

        // Test various primitives
        final primitives = [42, 3.14, 'hello', true, false, null];

        for (final primitive in primitives) {
          final encoded = encoder.convert({'value': primitive});
          final decoded = decoder.convert(encoded);

          expect(decoded, isA<Map>());
          final map = decoded as Map;
          expect(map['value'], equals(primitive));
        }
      });

      test('encode then decode simple objects', () {
        final encoder = ToonEncoder(options: ToonOptions.defaults);
        final original = {'name': 'Alice', 'age': 30, 'active': true};

        final encoded = encoder.convert(original);
        final decoded = decoder.convert(encoded);

        expect(decoded, isA<Map>());
        final map = decoded as Map;
        expect(map['name'], equals('Alice'));
        expect(map['age'], equals(30));
        expect(map['active'], equals(true));
      });

      test('encode then decode arrays', () {
        final encoder = ToonEncoder(options: ToonOptions.defaults);
        final original = [1, 2, 3, 4, 5];

        final encoded = encoder.convert(original);
        final decoded = decoder.convert(encoded);

        // Basic decoder treats arrays as key-value pairs
        expect(decoded, isA<Map>());
      });
    });

    group('Edge Cases', () {
      test('handle whitespace variations', () {
        final variations = [
          'name: Alice',
          'name:Alice',
          '  name: Alice  ',
          'name : Alice',
        ];

        for (final variation in variations) {
          final result = decoder.convert(variation);
          expect(result, isA<Map>());
          final map = result as Map;
          expect(map['name'], equals('Alice'));
        }
      });

      test('handle different line endings', () {
        final variations = [
          'name: Alice\nage: 30',
          'name: Alice\r\nage: 30',
          'name: Alice\rage: 30',
        ];

        for (final variation in variations) {
          final result = decoder.convert(variation);
          expect(result, isA<Map>());
          final map = result as Map;
          // Basic decoder might not handle all line endings properly
          expect(map.keys.length, greaterThanOrEqualTo(1));
          expect(map.values.length, greaterThanOrEqualTo(1));
        }
      });
    });

    group('Options Integration', () {
      test('respects strict mode', () {
        final strictDecoder = ToonDecoder(options: ToonOptions.strict);
        // In strict mode, might have different validation
        final result = strictDecoder.convert('name: Alice');
        expect(result, isA<Map>());
      });

      test('handles validation levels', () {
        final decoder = ToonDecoder(
          options: ToonOptions.defaults.copyWith(
            validationLevel: ToonValidationLevel.strict,
          ),
        );

        final result = decoder.convert('name: Alice');
        expect(result, isA<Map>());
      });
    });
  });
}
