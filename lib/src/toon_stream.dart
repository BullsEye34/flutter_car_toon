/// TOON streaming support for large data processing
library;

import 'dart:async';
import 'dart:convert';

import 'toon_options.dart';
import 'toon_codec.dart';

/// Stream-based TOON processor for handling large datasets
class ToonStream {
  /// Create a TOON stream with the given options
  ToonStream({ToonOptions? options})
    : _options = options ?? ToonOptions.defaults;

  final ToonOptions _options;

  /// Create a stream from a file path
  static Stream<String> fromFile(String filePath) {
    // TODO: Implement file streaming
    throw UnimplementedError('File streaming not yet implemented');
  }

  /// Create a stream from a string source
  static Stream<String> fromString(String source) {
    return Stream.fromIterable(source.split('\n'));
  }

  /// Decode a stream of TOON lines to objects
  Stream<dynamic> decode(Stream<String> input) async* {
    final codec = ToonCodec(options: _options);
    final buffer = StringBuffer();

    await for (final line in input) {
      buffer.writeln(line);

      // Try to parse complete objects
      final content = buffer.toString().trim();
      if (content.isNotEmpty) {
        try {
          final result = codec.decode(content);
          yield result;
          buffer.clear();
        } catch (e) {
          // Continue accumulating lines
        }
      }
    }

    // Process any remaining content
    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      final codec = ToonCodec(options: _options);
      yield codec.decode(remaining);
    }
  }

  /// Encode a stream of objects to TOON format
  Stream<String> encode(Stream<dynamic> input) async* {
    final codec = ToonCodec(options: _options);

    await for (final object in input) {
      yield codec.encode(object);
    }
  }

  /// Transform a stream of JSON to TOON
  Stream<String> fromJson(Stream<String> jsonStream) async* {
    final toonCodec = ToonCodec(options: _options);

    await for (final jsonString in jsonStream) {
      try {
        final object = json.decode(jsonString);
        yield toonCodec.encode(object);
      } catch (e) {
        // Skip invalid JSON
      }
    }
  }

  /// Transform a stream of TOON to JSON
  Stream<String> toJson(Stream<String> toonStream) async* {
    final toonCodec = ToonCodec(options: _options);

    await for (final toonString in toonStream) {
      try {
        final object = toonCodec.decode(toonString);
        yield json.encode(object);
      } catch (e) {
        // Skip invalid TOON
      }
    }
  }
}
