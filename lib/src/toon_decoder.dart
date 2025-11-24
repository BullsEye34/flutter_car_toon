/// TOON decoder for converting TOON format to Dart objects
library;

import 'dart:convert' as convert;
import 'toon_options.dart';
import 'toon_error.dart';
import 'toon_converter.dart';

/// TOON decoder that parses TOON string format to Dart objects
class ToonDecoder extends convert.Converter<String, Object?> {
  /// Creates a new TOON decoder with the given options
  ToonDecoder({ToonOptions? options, ToonConverterRegistry? converterRegistry});

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

  /// Parse TOON format with support for arrays and complex structures
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

    // Handle TOON structures with colons
    if (trimmed.contains(':')) {
      return _parseComplexToon(trimmed);
    }

    // Return as string if nothing else matches
    return trimmed;
  }

  /// Parse complex TOON structures including arrays and objects
  dynamic _parseComplexToon(String source) {
    final lines = source.split('\n');
    final result = <String, dynamic>{};

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final colonIndex = line.indexOf(':');
      if (colonIndex <= 0) continue;

      final keyPart = line.substring(0, colonIndex).trim();
      final valuePart = line.substring(colonIndex + 1).trim();

      // Check if this is a tabular array format: key[count]{fields}:
      if (keyPart.contains('[') &&
          keyPart.contains('{') &&
          keyPart.endsWith('}')) {
        final parsed = _parseTabularArray(keyPart, valuePart, lines, i);
        result[parsed['key']] = parsed['value'];
        i = parsed['nextIndex'] - 1; // -1 because loop will increment
      }
      // Check if this is an inline array: key[count]: value,value,value
      else if (keyPart.contains('[') &&
          keyPart.endsWith(']') &&
          valuePart.isNotEmpty) {
        final parsed = _parseInlineArray(keyPart, valuePart);
        result[parsed['key']] = parsed['value'];
      }
      // Handle nested objects (indented content)
      else if (valuePart.isEmpty &&
          i + 1 < lines.length &&
          lines[i + 1].startsWith('  ')) {
        final parsed = _parseNestedObject(keyPart, lines, i + 1);
        result[keyPart] = parsed['value'];
        i = parsed['nextIndex'] - 1; // -1 because loop will increment
      }
      // Simple key-value pair
      else {
        result[keyPart] = _parseSimpleToon(valuePart);
      }
    }

    return result;
  }

  /// Parse tabular array format: cars[2]{make,model,year}:
  Map<String, dynamic> _parseTabularArray(
    String keyPart,
    String valuePart,
    List<String> lines,
    int startIndex,
  ) {
    // Extract key name from cars[2]{make,model,year}
    final bracketIndex = keyPart.indexOf('[');
    final key = keyPart.substring(0, bracketIndex);

    // Extract field names from {make,model,year}
    final braceStart = keyPart.indexOf('{');
    final braceEnd = keyPart.indexOf('}');
    final fieldsStr = keyPart.substring(braceStart + 1, braceEnd);
    final fieldNames = fieldsStr.split(',').map((f) => f.trim()).toList();

    final arrayResult = <Map<String, dynamic>>[];
    int nextIndex = startIndex + 1;

    // Parse data rows
    for (int i = startIndex + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) break;

      // Check if this line starts with spaces (indicating it's part of the array)
      if (!lines[i].startsWith('    ')) break;

      final values = _parseRowValues(line, fieldNames.length);
      if (values.length == fieldNames.length) {
        final rowMap = <String, dynamic>{};
        for (int j = 0; j < fieldNames.length; j++) {
          rowMap[fieldNames[j]] = _parseValue(values[j]);
        }
        arrayResult.add(rowMap);
      }
      nextIndex = i + 1;
    }

    return {'key': key, 'value': arrayResult, 'nextIndex': nextIndex};
  }

  /// Parse inline array format: tags[3]: admin,ops,dev
  Map<String, dynamic> _parseInlineArray(String keyPart, String valuePart) {
    // Extract key name from tags[3]
    final bracketIndex = keyPart.indexOf('[');
    final key = keyPart.substring(0, bracketIndex);

    // Parse comma-separated values
    final values = valuePart
        .split(',')
        .map((v) => _parseValue(v.trim()))
        .toList();

    return {'key': key, 'value': values};
  }

  /// Parse nested object with indented content
  Map<String, dynamic> _parseNestedObject(
    String key,
    List<String> lines,
    int startIndex,
  ) {
    final nestedContent = <String>[];
    int nextIndex = startIndex;

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('  ')) {
        // Remove one level of indentation
        nestedContent.add(line.substring(2));
        nextIndex = i + 1;
      } else if (line.trim().isEmpty) {
        nestedContent.add('');
        nextIndex = i + 1;
      } else {
        break;
      }
    }

    final nestedSource = nestedContent.join('\n').trim();
    final nestedValue = nestedSource.isNotEmpty
        ? _parseComplexToon(nestedSource)
        : {};

    return {'value': nestedValue, 'nextIndex': nextIndex};
  }

  /// Parse row values that may contain inline arrays
  List<String> _parseRowValues(String line, int expectedCount) {
    final values = <String>[];
    int pos = 0;

    while (pos < line.length && values.length < expectedCount) {
      if (pos >= line.length) break;

      // Skip whitespace
      while (pos < line.length && line[pos] == ' ') {
        pos++;
      }
      if (pos >= line.length) break;

      // Check for inline array format [count]: value,value,value
      if (line[pos] == '[') {
        final closeBracket = line.indexOf(']', pos);
        if (closeBracket != -1 &&
            closeBracket + 1 < line.length &&
            line[closeBracket + 1] == ':') {
          // Found inline array format
          final arrayCountStr = line.substring(pos + 1, closeBracket);
          final arrayCount = int.tryParse(arrayCountStr.trim()) ?? 0;
          pos = closeBracket + 2; // Skip ]:

          // Skip spaces after colon
          while (pos < line.length && line[pos] == ' ') {
            pos++;
          }

          // Collect array values
          final arrayValues = <String>[];
          for (int i = 0; i < arrayCount && pos < line.length; i++) {
            final start = pos;
            // Find next comma or end of line
            while (pos < line.length && line[pos] != ',') {
              pos++;
            }

            final value = line.substring(start, pos).trim();
            if (value.isNotEmpty) arrayValues.add(value);

            if (pos < line.length && line[pos] == ',') pos++; // Skip comma
            while (pos < line.length && line[pos] == ' ') {
              pos++; // Skip spaces
            }
          }

          values.add('[${arrayValues.join(',')}]');

          // After array is parsed, continue to next field
          // pos should already be positioned after the last array value and comma
        } else {
          // Regular value starting with [
          final start = pos;
          while (pos < line.length && line[pos] != ',') {
            pos++;
          }
          values.add(line.substring(start, pos).trim());
          if (pos < line.length && line[pos] == ',') pos++; // Skip comma
        }
      } else {
        // Regular value
        final start = pos;
        while (pos < line.length && line[pos] != ',') {
          pos++;
        }
        values.add(line.substring(start, pos).trim());
        if (pos < line.length && line[pos] == ',') pos++; // Skip comma
      }
    }

    return values;
  }

  /// Parse individual values with type detection
  dynamic _parseValue(String value) {
    final trimmed = value.trim();

    // Handle array format [value1,value2,value3]
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final arrayContent = trimmed.substring(1, trimmed.length - 1);
      return arrayContent.split(',').map((v) => _parseValue(v.trim())).toList();
    }

    // Handle primitives
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

    // Return as string
    return trimmed;
  }
}
