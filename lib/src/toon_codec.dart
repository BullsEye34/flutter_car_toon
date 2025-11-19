/// TOON codec for encoding and decoding TOON format
library;

import 'dart:convert' as convert;

import 'toon_options.dart';
import 'toon_encoder.dart';
import 'toon_decoder.dart';
import 'toon_converter.dart';

/// Codec for TOON (Token-Oriented Object Notation) format
///
/// This codec provides encoding and decoding functionality similar to
/// dart:convert's JsonCodec but for the TOON format.
///
/// Example usage:
/// ```dart
/// final codec = ToonCodec();
///
/// // Encoding
/// final data = {'name': 'Alice', 'age': 30};
/// final encoded = codec.encode(data);
/// print(encoded); // name: Alice\nage: 30
///
/// // Decoding
/// final decoded = codec.decode(encoded);
/// print(decoded); // {name: Alice, age: 30}
/// ```
class ToonCodec extends convert.Codec<Object?, String> {
  /// Creates a TOON codec with optional configuration
  const ToonCodec({
    ToonOptions? options,
    ToonConverterRegistry? converterRegistry,
  }) : _options = options,
       _converterRegistry = converterRegistry;

  final ToonOptions? _options;
  final ToonConverterRegistry? _converterRegistry;

  /// Get the effective options (with defaults)
  ToonOptions get options => _options ?? ToonOptions.defaults;

  /// Get the effective converter registry (with defaults)
  ToonConverterRegistry get converterRegistry =>
      _converterRegistry ?? globalToonConverterRegistry;

  @override
  ToonEncoder get encoder =>
      ToonEncoder(options: options, converterRegistry: converterRegistry);

  @override
  ToonDecoder get decoder =>
      ToonDecoder(options: options, converterRegistry: converterRegistry);

  /// Encode a Dart object to TOON format string
  ///
  /// Example:
  /// ```dart
  /// final codec = ToonCodec();
  /// final result = codec.encode({'name': 'Alice', 'tags': ['admin', 'user']});
  /// // Result: "name: Alice\ntags[2]: admin,user"
  /// ```
  @override
  String encode(Object? input) => encoder.encode(input);

  /// Decode a TOON format string to Dart objects
  ///
  /// Example:
  /// ```dart
  /// final codec = ToonCodec();
  /// final result = codec.decode('name: Alice\nage: 30');
  /// // Result: {'name': 'Alice', 'age': 30}
  /// ```
  @override
  Object? decode(String encoded) => decoder.decode(encoded);

  /// Create a codec with modified options
  ToonCodec copyWith({
    ToonOptions? options,
    ToonConverterRegistry? converterRegistry,
  }) {
    return ToonCodec(
      options: options ?? _options,
      converterRegistry: converterRegistry ?? _converterRegistry,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToonCodec &&
          runtimeType == other.runtimeType &&
          _options == other._options &&
          _converterRegistry == other._converterRegistry;

  @override
  int get hashCode => _options.hashCode ^ _converterRegistry.hashCode;

  @override
  String toString() => 'ToonCodec(options: $options)';
}

/// Global TOON codec instance for convenience
const toonCodec = ToonCodec();

/// Convenience class that provides static methods for TOON operations
///
/// Similar to dart:convert's json class but for TOON format.
class toon {
  toon._();

  /// Encode a Dart object to TOON format string
  ///
  /// Example:
  /// ```dart
  /// final result = toon.encode({'name': 'Alice', 'age': 30});
  /// print(result); // name: Alice\nage: 30
  /// ```
  static String encode(Object? object, {ToonOptions? options}) {
    return ToonCodec(options: options).encode(object);
  }

  /// Decode a TOON format string to Dart objects
  ///
  /// Example:
  /// ```dart
  /// final result = toon.decode('name: Alice\nage: 30');
  /// print(result); // {name: Alice, age: 30}
  /// ```
  static dynamic decode(String source, {ToonOptions? options}) {
    return ToonCodec(options: options).decode(source);
  }

  /// Get the default TOON codec
  static const ToonCodec codec = toonCodec;

  /// Get a TOON encoder with optional configuration
  static ToonEncoder encoder({ToonOptions? options}) {
    return ToonEncoder(options: options);
  }

  /// Get a TOON decoder with optional configuration
  static ToonDecoder decoder({ToonOptions? options}) {
    return ToonDecoder(options: options);
  }
}
