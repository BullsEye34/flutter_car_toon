/// BigInt converter for TOON format
library;

import '../toon_converter.dart';
import '../toon_options.dart';
import '../toon_error.dart';

/// Converter for BigInt objects in TOON format
class BigIntToonConverter extends ToonConverter<BigInt> {
  /// Create a BigInt converter
  const BigIntToonConverter();

  @override
  String encode(BigInt object, ToonOptions options) {
    return object.toString();
  }

  @override
  BigInt decode(String value, ToonOptions options) {
    try {
      return BigInt.parse(value);
    } catch (e) {
      throw ToonConversionError(
        'Cannot parse BigInt from: $value',
        sourceType: String,
        targetType: BigInt,
        value: value,
      );
    }
  }

  @override
  int get priority => 10;
}
