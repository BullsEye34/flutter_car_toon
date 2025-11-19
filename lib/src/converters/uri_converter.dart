/// Uri converter for TOON format
library;

import '../toon_converter.dart';
import '../toon_options.dart';
import '../toon_error.dart';

/// Converter for Uri objects in TOON format
class UriToonConverter extends ToonConverter<Uri> {
  /// Create a Uri converter
  const UriToonConverter();

  @override
  String encode(Uri object, ToonOptions options) {
    return object.toString();
  }

  @override
  Uri decode(String value, ToonOptions options) {
    try {
      return Uri.parse(value);
    } catch (e) {
      throw ToonConversionError(
        'Cannot parse Uri from: $value',
        sourceType: String,
        targetType: Uri,
        value: value,
      );
    }
  }

  @override
  int get priority => 10;
}
