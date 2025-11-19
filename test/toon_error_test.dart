import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/src/toon_error.dart';
import 'package:flutter_car_toon/src/constants.dart';

void main() {
  group('ToonError Tests', () {
    group('Base Error Classes', () {
      test('creates base ToonEncodingError', () {
        final error = ToonEncodingError(
          'Cannot encode object',
          object: DateTime.now(),
          path: ['user', 'createdAt'],
        );

        expect(error.message, 'Cannot encode object');
        expect(error.object, isA<DateTime>());
        expect(error.path, ['user', 'createdAt']);
        expect(error.pathString, 'user.createdAt');
        expect(error.severity, ToonErrorSeverity.error);
      });

      test('creates ToonDecodingError with position info', () {
        final error = ToonDecodingError(
          'Invalid number format',
          offset: 20,
          source: 'name: John\nage: invalid_number',
        );

        expect(error.message, 'Invalid number format');
        expect(error.offset, 20);
        expect(error.source, 'name: John\nage: invalid_number');
      });

      test('creates ToonValidationError with rule info', () {
        final error = ToonValidationError(
          'Field validation failed',
          violatedRule: 'age must be positive',
          suggestion: 'Use a positive number',
        );

        expect(error.message, 'Field validation failed');
        expect(error.violatedRule, 'age must be positive');
        expect(error.suggestion, 'Use a positive number');
      });

      test('creates ToonSyntaxError', () {
        final error = ToonSyntaxError(
          'Missing colon separator',
          line: 3,
          column: 15,
        );

        expect(error.message, 'Missing colon separator');
        expect(error.line, 3);
        expect(error.column, 15);
      });
    });

    group('Error Severity', () {
      test('supports different severity levels', () {
        final warning = ToonValidationError(
          'Deprecated syntax',
          severity: ToonErrorSeverity.warning,
        );

        final info = ToonValidationError(
          'Optimization suggestion',
          severity: ToonErrorSeverity.info,
        );

        expect(warning.severity, ToonErrorSeverity.warning);
        expect(info.severity, ToonErrorSeverity.info);
      });
    });

    group('Error Location', () {
      test('formats location with line and column', () {
        final error = ToonDecodingError('Parse error', line: 5, column: 12);

        expect(error.location, 'line 5, column 12');
      });

      test('formats location with line only', () {
        final error = ToonDecodingError('Parse error', line: 3);

        expect(error.location, 'line 3');
      });

      test('formats location with offset only', () {
        final error = ToonDecodingError('Parse error', offset: 25);

        expect(error.location, 'offset 25');
      });

      test('handles unknown location', () {
        final error = ToonDecodingError('Parse error');

        expect(error.location, 'unknown location');
      });
    });

    group('Error Context', () {
      test('includes context information', () {
        final context = {
          'file': 'config.toon',
          'operation': 'parse',
          'expected': 'object',
          'actual': 'string',
        };

        final error = ToonDecodingError('Type mismatch', context: context);

        expect(error.context, context);
        expect(error.context!['file'], 'config.toon');
        expect(error.context!['operation'], 'parse');
      });
    });

    group('Error Inheritance', () {
      test('ToonSyntaxError inherits from ToonDecodingError', () {
        final error = ToonSyntaxError('Syntax issue');

        expect(error, isA<ToonDecodingError>());
        expect(error, isA<ToonError>());
        expect(error, isA<Exception>());
      });

      test('all error types implement Exception', () {
        final encodingError = ToonEncodingError('Encoding failed');
        final decodingError = ToonDecodingError('Decoding failed');
        final validationError = ToonValidationError('Validation failed');

        expect(encodingError, isA<Exception>());
        expect(decodingError, isA<Exception>());
        expect(validationError, isA<Exception>());
      });
    });

    group('Error Messages', () {
      test('provides clear error messages', () {
        final error = ToonDecodingError(
          'Unexpected token at position 15',
          offset: 15,
          expectedType: String,
          actualValue: 'null',
        );

        expect(error.message, contains('Unexpected token'));
        expect(error.message, contains('position 15'));
        expect(error.expectedType, String);
        expect(error.actualValue, 'null');
      });
    });

    group('Error Utilities', () {
      test('error supports string representation', () {
        final error = ToonDecodingError('Parse failed', line: 2, column: 8);

        final errorString = error.toString();
        expect(errorString, contains('ToonDecodingError'));
        expect(errorString, contains('Parse failed'));
      });
    });
  });
}
