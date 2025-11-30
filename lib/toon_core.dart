// Pure Dart TOON library exports (no Flutter dependencies)
// Use this for CLI tools and server-side Dart applications
library;

// Core TOON functionality
export 'src/toon_codec.dart';
export 'src/toon_encoder.dart';
export 'src/toon_decoder.dart';
export 'src/toon_converter.dart';
export 'src/toon_options.dart';
export 'src/toon_error.dart';
export 'src/toon_validator.dart';
export 'src/toon_stream.dart';

// Annotations and code generation
export 'src/annotations/toon_serializable.dart';
export 'src/annotations/toon_field.dart';

// Converters
export 'src/converters/date_time_converter.dart';
export 'src/converters/duration_converter.dart';
export 'src/converters/uri_converter.dart';
export 'src/converters/big_int_converter.dart';

// Utilities
export 'src/utils/toon_utils.dart';
export 'src/utils/string_utils.dart';
export 'src/utils/validation_utils.dart';

// Constants
export 'src/constants.dart';

import 'src/toon_codec.dart';
import 'src/toon_options.dart';

/// Global TOON codec instance for convenience
final toon = ToonCodec();

/// Convenience function to encode data to TOON format
///
/// Example:
/// ```dart
/// final data = {'name': 'Alice', 'age': 30};
/// final encoded = toonEncode(data);
/// print(encoded); // name: Alice\nage: 30
/// ```
String toonEncode(Object? object, {ToonOptions? options}) {
  return ToonCodec(options: options).encode(object);
}

/// Convenience function to decode TOON format to Dart objects
///
/// Example:
/// ```dart
/// final toonString = 'name: Alice\nage: 30';
/// final decoded = toonDecode(toonString);
/// print(decoded); // {name: Alice, age: 30}
/// ```
dynamic toonDecode(String source, {ToonOptions? options}) {
  return ToonCodec(options: options).decode(source);
}
