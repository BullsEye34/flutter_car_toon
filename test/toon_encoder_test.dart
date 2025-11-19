/// Comprehensive tests for ToonEncoder
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  group('ToonEncoder Tests', () {
    late ToonEncoder encoder;

    setUp(() {
      encoder = ToonEncoder(options: ToonOptions.defaults);
    });

    group('Primitive Encoding', () {
      test('encode strings', () {
        expect(encoder.convert('hello'), equals('hello'));
        expect(encoder.convert('hello world'), equals('hello world'));
        expect(encoder.convert(''), equals('""'));
      });

      test('encode numbers', () {
        expect(encoder.convert(42), equals('42'));
        expect(encoder.convert(3.14), equals('3.14'));
        expect(encoder.convert(0), equals('0'));
        expect(encoder.convert(-1), equals('-1'));
      });

      test('encode booleans', () {
        expect(encoder.convert(true), equals('true'));
        expect(encoder.convert(false), equals('false'));
      });

      test('encode null', () {
        expect(encoder.convert(null), equals('null'));
      });
    });

    group('Array Encoding', () {
      test('encode simple arrays', () {
        expect(encoder.convert([1, 2, 3]), equals('[3]: 1,2,3'));
        expect(encoder.convert(['a', 'b']), equals('[2]: a,b'));
        expect(encoder.convert([]), equals('[0]:'));
      });

      test('encode arrays with mixed types', () {
        final result = encoder.convert([1, 'hello', true, null]);
        expect(result, equals('[4]: 1,hello,true,null'));
      });

      test('encode nested arrays', () {
        final result = encoder.convert([
          [1, 2],
          [3, 4],
        ]);
        expect(result, contains('[2]'));
      });
    });

    group('Object Encoding', () {
      test('encode simple objects', () {
        final result = encoder.convert({'name': 'Alice', 'age': 30});
        expect(result, contains('name: Alice'));
        expect(result, contains('age: 30'));
      });

      test('encode nested objects', () {
        final data = {
          'user': {
            'name': 'Alice',
            'profile': {'age': 30},
          },
        };
        final result = encoder.convert(data);
        expect(result, contains('user:'));
        expect(result, contains('name: Alice'));
        expect(result, contains('age: 30'));
      });

      test('encode empty objects', () {
        expect(encoder.convert({}), equals(''));
      });
    });

    group('Complex Data Structures', () {
      test('encode object with arrays', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
          ],
          'count': 2,
        };
        final result = encoder.convert(data);
        expect(result, contains('users[2]{name,age}:'));
        expect(result, contains('Alice,30'));
        expect(result, contains('Bob,25'));
        expect(result, contains('count: 2'));
      });

      test('encode deeply nested structures', () {
        final data = {
          'level1': {
            'level2': {
              'level3': {'value': 'deep'},
            },
          },
        };
        final result = encoder.convert(data);
        expect(result, contains('level1:'));
        expect(result, contains('level2:'));
        expect(result, contains('level3:'));
        expect(result, contains('value: deep'));
      });
    });

    group('Special Cases', () {
      test('encode strings requiring quotes', () {
        final result = encoder.convert({'message': 'Hello, World!'});
        expect(result, contains('message: "Hello, World!"'));
      });

      test('encode numeric strings', () {
        final result = encoder.convert({'id': '123'});
        expect(result, contains('id: "123"'));
      });

      test('encode boolean strings', () {
        final result = encoder.convert({'flag': 'true'});
        expect(result, contains('flag: "true"'));
      });
    });

    group('Error Handling', () {
      test('throws error for unsupported types', () {
        expect(
          () => encoder.convert(DateTime.now()),
          throwsA(isA<ToonEncodingError>()),
        );
      });

      test('handles circular references', () {
        final map = <String, dynamic>{};
        map['self'] = map;

        expect(() => encoder.convert(map), throwsA(isA<ToonEncodingError>()));
      });

      test('respects max depth limit', () {
        final deeplyNested = <String, dynamic>{};
        var current = deeplyNested;

        // Create a deeply nested structure
        for (int i = 0; i < 100; i++) {
          current['next'] = <String, dynamic>{};
          current = current['next'];
        }

        expect(
          () => encoder.convert(deeplyNested),
          throwsA(isA<ToonEncodingError>()),
        );
      });
    });

    group('Options Integration', () {
      test('respects custom indentation', () {
        final encoder = ToonEncoder(
          options: ToonOptions.defaults.copyWith(indent: 4),
        );
        final data = {
          'nested': {'key': 'value'},
        };
        final result = encoder.convert(data);

        expect(result, contains('    key: value'));
      });

      test('respects strict mode', () {
        final encoder = ToonEncoder(options: ToonOptions.strict);
        // In strict mode, should handle validation differently
        final result = encoder.convert({'valid': 'data'});
        expect(result, contains('valid: data'));
      });
    });
  });
}
