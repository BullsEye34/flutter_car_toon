/// DateTime converter for TOON format
library;

import '../toon_converter.dart';
import '../toon_options.dart';
import '../toon_error.dart';

/// Converter for DateTime objects in TOON format
class DateTimeToonConverter extends ToonConverter<DateTime> {
  /// Create a DateTime converter
  const DateTimeToonConverter();

  @override
  String encode(DateTime object, ToonOptions options) {
    if (options.dateTimeFormat != null) {
      // Custom format would require additional formatting library
      return object.toIso8601String();
    }
    return object.toIso8601String();
  }

  @override
  DateTime decode(String value, ToonOptions options) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      throw ToonConversionError(
        'Cannot parse DateTime from: $value',
        sourceType: String,
        targetType: DateTime,
        value: value,
      );
    }
  }

  @override
  int get priority => 10;
}
