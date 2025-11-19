import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/src/toon_options.dart';
import 'package:flutter_car_toon/src/constants.dart';

void main() {
  group('ToonOptions Tests', () {
    group('Default Options', () {
      test('creates default options with correct values', () {
        final options = ToonOptions.defaults;

        expect(options.indent, kDefaultIndent);
        expect(options.delimiter, ToonDelimiter.comma);
        expect(options.keyFolding, ToonKeyFolding.none);
        expect(options.arrayStrategy, ToonArrayStrategy.auto);
        expect(options.validationLevel, ToonValidationLevel.basic);
        expect(options.strictMode, false);
        expect(options.compactOutput, false);
        expect(options.maxDepth, kMaxDepth);
      });
    });

    group('Predefined Option Sets', () {
      test('creates strict options', () {
        final options = ToonOptions.strict;

        expect(options.strictMode, true);
        expect(options.validationLevel, ToonValidationLevel.strict);
      });

      test('creates compact options', () {
        final options = ToonOptions.compact;

        expect(options.compactOutput, true);
        expect(options.delimiter, ToonDelimiter.comma);
        expect(options.keyFolding, ToonKeyFolding.safe);
      });

      test('creates pretty options', () {
        final options = ToonOptions.pretty;

        expect(options.compactOutput, false);
        expect(options.indent, greaterThan(0));
        expect(options.arrayStrategy, ToonArrayStrategy.auto);
      });

      test('creates performance options', () {
        final options = ToonOptions.performance;

        expect(options.validationLevel, ToonValidationLevel.none);
        expect(options.preserveOrder, false);
        expect(options.maxDepth, 50);
      });
    });

    group('Custom Options', () {
      test('creates custom options with specified values', () {
        final options = ToonOptions(
          indent: 4,
          delimiter: ToonDelimiter.tab,
          keyFolding: ToonKeyFolding.safe,
          arrayStrategy: ToonArrayStrategy.tabular,
          validationLevel: ToonValidationLevel.strict,
          strictMode: true,
          compactOutput: true,
          maxDepth: 50,
          preserveOrder: true,
          allowTrailingCommas: true,
        );

        expect(options.indent, 4);
        expect(options.delimiter, ToonDelimiter.tab);
        expect(options.keyFolding, ToonKeyFolding.safe);
        expect(options.arrayStrategy, ToonArrayStrategy.tabular);
        expect(options.validationLevel, ToonValidationLevel.strict);
        expect(options.strictMode, true);
        expect(options.compactOutput, true);
        expect(options.maxDepth, 50);
        expect(options.preserveOrder, true);
        expect(options.allowTrailingCommas, true);
      });
    });

    group('CopyWith Method', () {
      test('copies options with modifications', () {
        final original = ToonOptions.defaults;
        final modified = original.copyWith(
          indent: 8,
          strictMode: true,
          delimiter: ToonDelimiter.pipe,
        );

        expect(modified.indent, 8);
        expect(modified.strictMode, true);
        expect(modified.delimiter, ToonDelimiter.pipe);

        // Other values should remain the same
        expect(modified.keyFolding, original.keyFolding);
        expect(modified.arrayStrategy, original.arrayStrategy);
        expect(modified.validationLevel, original.validationLevel);
      });

      test('copyWith preserves original when no changes', () {
        final original = ToonOptions.defaults;
        final copy = original.copyWith();

        expect(copy.indent, original.indent);
        expect(copy.delimiter, original.delimiter);
        expect(copy.keyFolding, original.keyFolding);
        expect(copy.arrayStrategy, original.arrayStrategy);
        expect(copy.validationLevel, original.validationLevel);
        expect(copy.strictMode, original.strictMode);
        expect(copy.compactOutput, original.compactOutput);
        expect(copy.maxDepth, original.maxDepth);
      });
    });

    group('Enum Values', () {
      test('ToonDelimiter has correct symbols', () {
        expect(ToonDelimiter.comma.symbol, ',');
        expect(ToonDelimiter.tab.symbol, '\t');
        expect(ToonDelimiter.pipe.symbol, '|');

        expect(ToonDelimiter.comma.toString(), ',');
        expect(ToonDelimiter.tab.toString(), '\t');
        expect(ToonDelimiter.pipe.toString(), '|');
      });

      test('enum values are properly defined', () {
        expect(ToonKeyFolding.values, contains(ToonKeyFolding.none));
        expect(ToonKeyFolding.values, contains(ToonKeyFolding.safe));
        expect(ToonKeyFolding.values, contains(ToonKeyFolding.aggressive));

        expect(ToonArrayStrategy.values, contains(ToonArrayStrategy.auto));
        expect(ToonArrayStrategy.values, contains(ToonArrayStrategy.inline));
        expect(ToonArrayStrategy.values, contains(ToonArrayStrategy.tabular));
        expect(ToonArrayStrategy.values, contains(ToonArrayStrategy.list));

        expect(ToonValidationLevel.values, contains(ToonValidationLevel.none));
        expect(ToonValidationLevel.values, contains(ToonValidationLevel.basic));
        expect(
          ToonValidationLevel.values,
          contains(ToonValidationLevel.strict),
        );
      });
    });

    group('Integration with Codec', () {
      test('options work with encoder', () {
        final customOptions = ToonOptions(
          indent: 4,
          compactOutput: true,
          delimiter: ToonDelimiter.pipe,
        );

        // Test that options can be used (basic functionality test)
        expect(customOptions.indent, 4);
        expect(customOptions.compactOutput, true);
        expect(customOptions.delimiter.symbol, '|');
      });
    });
  });
}
