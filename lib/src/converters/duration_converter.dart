/// Duration converter for TOON format
library;

import '../toon_converter.dart';
import '../toon_options.dart';
import '../toon_error.dart';

/// Converter for Duration objects in TOON format
class DurationToonConverter extends ToonConverter<Duration> {
  /// Create a Duration converter
  const DurationToonConverter();

  @override
  String encode(Duration object, ToonOptions options) {
    return object.toString();
  }

  @override
  Duration decode(String value, ToonOptions options) {
    try {
      // Parse duration string in format like "1:30:00.000000"
      final parts = value.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secondsParts = parts[2].split('.');
        final seconds = int.parse(secondsParts[0]);
        final microseconds = secondsParts.length > 1
            ? int.parse(secondsParts[1].padRight(6, '0').substring(0, 6))
            : 0;

        return Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          microseconds: microseconds,
        );
      }

      // Try parsing as microseconds
      final microseconds = int.tryParse(value);
      if (microseconds != null) {
        return Duration(microseconds: microseconds);
      }

      throw FormatException('Invalid duration format');
    } catch (e) {
      throw ToonConversionError(
        'Cannot parse Duration from: $value',
        sourceType: String,
        targetType: Duration,
        value: value,
      );
    }
  }

  @override
  int get priority => 10;
}
