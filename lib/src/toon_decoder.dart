/// TOON decoder for converting TOON format to Dart objects
library;

import 'dart:convert' as convert;
import 'toon_options.dart';
import 'toon_error.dart';
import 'toon_converter.dart';

/// TOON decoder that parses TOON string format to Dart objects
class ToonDecoder extends convert.Converter<String, Object?> {
  /// Creates a new TOON decoder with the given options
  ToonDecoder({ToonOptions? options, ToonConverterRegistry? converterRegistry})
    : _options = options ?? ToonOptions.defaults,
      _converterRegistry = converterRegistry ?? globalToonConverterRegistry;

  final ToonOptions _options;
  final ToonConverterRegistry _converterRegistry;

  /// Decode the given TOON string to Dart objects
  @override
  Object? convert(String source) {
    return decode(source);
  }

  /// Decode the given TOON string to Dart objects
  dynamic decode(String source) {
    if (source.trim().isEmpty) {
      throw ToonDecodingError('Empty TOON source', source: source);
    }

    // Simple decoder implementation for basic functionality
    // Note: This basic implementation handles primitives and simple objects.
    // A full TOON parser implementation is planned for future versions.
    return _parseSimpleToon(source);
  }

  /// Simple TOON parser for basic cases
  dynamic _parseSimpleToon(String source) {
    final trimmed = source.trim();

    // Handle simple primitives
    if (trimmed == 'null') return null;
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;

    // Handle numbers
    final number = num.tryParse(trimmed);
    if (number != null) return number;

    // Handle quoted strings
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    }

    // Handle simple objects (key: value pairs)
    if (trimmed.contains(':')) {
      final result = <String, dynamic>{};
      final lines = trimmed.split('\n');

      for (final line in lines) {
        final colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
          final key = line.substring(0, colonIndex).trim();
          final valueStr = line.substring(colonIndex + 1).trim();
          result[key] = _parseSimpleToon(valueStr);
        }
      }
      return result;
    }

    // Return as string if nothing else matches
    return trimmed;
  }
}
