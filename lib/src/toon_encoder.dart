/// TOON encoder for converting Dart objects to TOON format
library;

import 'dart:collection';
import 'dart:convert' as convert;
import 'toon_options.dart';
import 'toon_error.dart';
import 'toon_converter.dart';
import 'constants.dart';

/// TOON encoder that converts Dart objects to TOON string format
class ToonEncoder extends convert.Converter<Object?, String> {
  /// Creates a new TOON encoder with the given options
  ToonEncoder({ToonOptions? options, ToonConverterRegistry? converterRegistry})
    : _options = options ?? ToonOptions.defaults,
      _converterRegistry = converterRegistry ?? globalToonConverterRegistry;

  final ToonOptions _options;
  final ToonConverterRegistry _converterRegistry;
  final Set<Object> _visitedObjects = <Object>{};
  int _currentDepth = 0;

  /// Encode the given object to TOON format
  @override
  String convert(Object? object) {
    return encode(object);
  }

  /// Encode the given object to TOON format
  String encode(Object? object) {
    try {
      _visitedObjects.clear();
      _currentDepth = 0;

      final result = _encodeValue(object, 0);

      // Remove trailing newline for single values
      if (!result.contains('\n') || result.endsWith('\n')) {
        return result.trimRight();
      }

      return result;
    } finally {
      _visitedObjects.clear();
    }
  }

  /// Encode a value at the given indentation level
  String _encodeValue(Object? value, int indentLevel) {
    _checkDepth();

    // Handle null
    if (value == null) {
      return 'null';
    }

    // Check for circular references
    if (_isObjectType(value) && _visitedObjects.contains(value)) {
      throw ToonEncodingError(
        'Circular reference detected',
        object: value,
        context: {'depth': _currentDepth},
      );
    }

    // Try custom converters first
    final converter = _converterRegistry.getConverter(value);
    if (converter != null) {
      final converted = converter.encode(value, _options);
      if (converted != null) {
        return converted;
      }
    }

    // Add to visited objects for circular reference detection
    if (_isObjectType(value)) {
      _visitedObjects.add(value);
    }

    try {
      // Handle different types
      if (value is Map) {
        return _encodeMap(value, indentLevel);
      } else if (value is List) {
        return _encodeList(value, indentLevel);
      } else if (value is String) {
        return _encodeString(value);
      } else if (value is num) {
        return _encodeNumber(value);
      } else if (value is bool) {
        return value ? 'true' : 'false';
      } else {
        // Try to convert to JSON-serializable form
        return _encodeGeneric(value, indentLevel);
      }
    } finally {
      if (_isObjectType(value)) {
        _visitedObjects.remove(value);
      }
    }
  }

  /// Encode a Map as a TOON object
  String _encodeMap(Map<dynamic, dynamic> map, int indentLevel) {
    if (map.isEmpty) {
      return _options.compactOutput ? '{}' : '';
    }

    final buffer = StringBuffer();
    final nextIndent = ' ' * ((indentLevel + 1) * _options.indent);

    // Sort keys if not preserving order
    Iterable<dynamic> keys = map.keys;
    if (!_options.preserveOrder && map is! LinkedHashMap) {
      keys = keys.toList()
        ..sort((a, b) => a.toString().compareTo(b.toString()));
    }

    bool first = true;
    for (final key in keys) {
      if (!first && !_options.compactOutput) {
        buffer.writeln();
      }
      first = false;

      final keyStr = _encodeKey(key);
      final value = map[key];

      if (value is Map && value.isNotEmpty) {
        buffer.write('$nextIndent$keyStr:');
        if (!_options.compactOutput) buffer.writeln();
        buffer.write(_encodeValue(value, indentLevel + 1));
      } else if (value is List && value.isNotEmpty) {
        buffer.write('$nextIndent$keyStr');
        buffer.write(_encodeValue(value, indentLevel + 1));
      } else {
        final valueStr = _encodeValue(value, indentLevel + 1);
        buffer.write('$nextIndent$keyStr: $valueStr');
      }
    }

    return buffer.toString();
  }

  /// Encode a List as a TOON array
  String _encodeList(List<dynamic> list, int indentLevel) {
    if (list.isEmpty) {
      return '[0]:';
    }

    final strategy = _determineArrayStrategy(list);

    switch (strategy) {
      case ToonArrayStrategy.inline:
        return _encodeInlineArray(list, indentLevel);
      case ToonArrayStrategy.tabular:
        return _encodeTabularArray(list, indentLevel);
      case ToonArrayStrategy.list:
        return _encodeListArray(list, indentLevel);
      default:
        return _encodeInlineArray(list, indentLevel);
    }
  }

  /// Encode an inline array (for primitives)
  String _encodeInlineArray(List<dynamic> list, int indentLevel) {
    final delimiter = _options.delimiter.symbol;
    final elements = list
        .map((e) => _encodeValue(e, indentLevel))
        .join(delimiter);
    return '[${list.length}]: $elements';
  }

  /// Encode a tabular array (for uniform objects)
  String _encodeTabularArray(List<dynamic> list, int indentLevel) {
    if (list.isEmpty) return '[0]:';

    // Get field names from first object
    final firstObj = list.first as Map<dynamic, dynamic>;
    final fields = firstObj.keys.map((k) => _encodeKey(k)).toList();

    final buffer = StringBuffer();
    final delimiter = _options.delimiter.symbol;

    // Write header
    buffer.write('[${list.length}]{${fields.join(',')}}:');
    if (!_options.compactOutput) buffer.writeln();

    final indent = ' ' * ((indentLevel + 1) * _options.indent);

    // Write rows
    for (int i = 0; i < list.length; i++) {
      if (i > 0 && !_options.compactOutput) buffer.writeln();

      final obj = list[i] as Map<dynamic, dynamic>;
      final values = fields
          .map((field) {
            final key = _findOriginalKey(firstObj, field);
            return _encodeValue(obj[key], indentLevel + 1);
          })
          .join(delimiter);

      buffer.write('$indent$values');
    }

    return buffer.toString();
  }

  /// Encode a list array (for mixed types)
  String _encodeListArray(List<dynamic> list, int indentLevel) {
    final buffer = StringBuffer();
    final indent = ' ' * ((indentLevel + 1) * _options.indent);

    buffer.write('[${list.length}]:');
    if (!_options.compactOutput) buffer.writeln();

    for (int i = 0; i < list.length; i++) {
      if (i > 0 && !_options.compactOutput) buffer.writeln();

      final value = list[i];
      if (value is Map && value.isNotEmpty) {
        buffer.write('$indent-');
        if (!_options.compactOutput) buffer.write(' ');
        final objStr = _encodeValue(value, indentLevel + 1);
        if (objStr.startsWith('\n')) {
          buffer.write(objStr);
        } else {
          buffer.write(objStr);
        }
      } else {
        final valueStr = _encodeValue(value, indentLevel + 1);
        buffer.write('$indent- $valueStr');
      }
    }

    return buffer.toString();
  }

  /// Encode a string with proper quoting and escaping
  String _encodeString(String str) {
    if (_needsQuoting(str)) {
      return '"${_escapeString(str)}"';
    }
    return str;
  }

  /// Check if a string needs to be quoted
  bool _needsQuoting(String str) {
    if (str.isEmpty) return true;

    // Check for structural characters
    for (final char in kStructuralChars) {
      if (str.contains(char)) return true;
    }

    // Check for delimiter
    if (str.contains(_options.delimiter.symbol)) return true;

    // Check for leading/trailing whitespace
    if (str.trim() != str) return true;

    // Check if it looks like a boolean, number, or null
    final lower = str.toLowerCase();
    if (lower == 'true' || lower == 'false' || lower == 'null') return true;
    if (num.tryParse(str) != null) return true;

    return false;
  }

  /// Escape a string for TOON format
  String _escapeString(String str) {
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      final escape = kEscapeSequences[char];
      if (escape != null) {
        buffer.write(escape);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Encode a number value
  String _encodeNumber(num number) {
    // Handle special values
    if (number.isNaN || number.isInfinite) {
      return 'null';
    }

    // Handle negative zero
    if (number == 0 && number.isNegative) {
      return '0';
    }

    // Use canonical decimal representation
    if (number is double) {
      final str = number.toString();
      if (str.contains('e') || str.contains('E')) {
        // Convert scientific notation to decimal
        final fixed = number.toStringAsFixed(
          number.truncate() == number ? 0 : 10,
        );
        return fixed.replaceAll(RegExp(r'\.?0+$'), '');
      }
      return str;
    }

    return number.toString();
  }

  /// Encode a key for TOON format
  String _encodeKey(dynamic key) {
    if (key is String) {
      return _encodeString(key);
    }
    return _encodeString(key.toString());
  }

  /// Encode a generic object by trying to convert it to a Map
  String _encodeGeneric(Object object, int indentLevel) {
    // Try to convert using toJson() method
    try {
      final json = (object as dynamic).toJson();
      if (json is Map) {
        return _encodeValue(json, indentLevel);
      }
    } catch (e) {
      // Ignore and fall through to error
    }

    throw ToonEncodingError(
      'Cannot encode object of type ${object.runtimeType}',
      object: object,
      context: {'type': object.runtimeType.toString()},
    );
  }

  /// Determine the best array encoding strategy
  ToonArrayStrategy _determineArrayStrategy(List<dynamic> list) {
    if (_options.arrayStrategy != ToonArrayStrategy.auto) {
      return _options.arrayStrategy;
    }

    if (list.isEmpty) return ToonArrayStrategy.inline;

    // Check if all elements are primitives
    bool allPrimitives = list.every(
      (e) => e == null || e is String || e is num || e is bool,
    );

    if (allPrimitives) {
      return ToonArrayStrategy.inline;
    }

    // Check if all elements are uniform objects
    if (list.every((e) => e is Map<dynamic, dynamic>)) {
      final maps = list.cast<Map<dynamic, dynamic>>();
      if (_areUniformMaps(maps)) {
        return ToonArrayStrategy.tabular;
      }
    }

    return ToonArrayStrategy.list;
  }

  /// Check if maps have uniform structure for tabular encoding
  bool _areUniformMaps(List<Map<dynamic, dynamic>> maps) {
    if (maps.isEmpty) return true;

    final firstKeys = maps.first.keys.toSet();
    return maps.every(
      (map) =>
          map.keys.toSet().difference(firstKeys).isEmpty &&
          firstKeys.difference(map.keys.toSet()).isEmpty,
    );
  }

  /// Find the original key corresponding to an encoded key
  dynamic _findOriginalKey(Map<dynamic, dynamic> map, String encodedKey) {
    for (final key in map.keys) {
      if (_encodeKey(key) == encodedKey) {
        return key;
      }
    }
    return encodedKey; // Fallback
  }

  /// Check if an object is a reference type (for circular detection)
  bool _isObjectType(Object? value) {
    return value != null && value is! String && value is! num && value is! bool;
  }

  /// Check if we've exceeded maximum nesting depth
  void _checkDepth() {
    if (_currentDepth >= _options.maxDepth) {
      throw ToonEncodingError(
        'Maximum nesting depth exceeded: ${_options.maxDepth}',
        context: {'maxDepth': _options.maxDepth, 'currentDepth': _currentDepth},
      );
    }
    _currentDepth++;
  }
}
