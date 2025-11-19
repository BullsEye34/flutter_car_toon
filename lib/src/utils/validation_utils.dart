/// Validation utility functions for TOON format
library;

import '../constants.dart';

/// Utility functions for validating TOON format and data
class ValidationUtils {
  ValidationUtils._();

  /// Validate that a string is a valid TOON key
  static bool isValidKey(String key) {
    if (key.isEmpty) return false;

    // Keys should not start or end with whitespace
    if (key.trim() != key) return false;

    // Keys should not contain structural characters unless quoted
    const invalid = {'\n', '\r', ':', '[', ']', '{', '}', '-'};
    return !invalid.any(key.contains);
  }

  /// Validate TOON array header syntax
  static ValidationResult validateArrayHeader(String header) {
    final regex = RegExp(r'^\[(\d+)(?:([,\t|])(?:\{([^}]+)\})?)?\]:?$');
    final match = regex.firstMatch(header.trim());

    if (match == null) {
      return ValidationResult.error('Invalid array header format: $header');
    }

    final lengthStr = match.group(1)!;
    final length = int.tryParse(lengthStr);
    if (length == null || length < 0) {
      return ValidationResult.error('Invalid array length: $lengthStr');
    }

    final delimiter = match.group(2);
    if (delimiter != null &&
        !ToonDelimiter.values.any((d) => d.symbol == delimiter)) {
      return ValidationResult.warning('Non-standard delimiter: $delimiter');
    }

    final fieldsStr = match.group(3);
    if (fieldsStr != null) {
      final fields = fieldsStr.split(',').map((f) => f.trim()).toList();
      for (final field in fields) {
        if (field.isEmpty) {
          return ValidationResult.error('Empty field name in array header');
        }
        if (!isValidKey(field)) {
          return ValidationResult.error('Invalid field name: $field');
        }
      }
    }

    return ValidationResult.success();
  }

  /// Validate TOON indentation
  static ValidationResult validateIndentation(
    String line,
    int lineNumber,
    int expectedIndent, {
    bool strictMode = false,
  }) {
    int actualIndent = 0;
    bool hasTab = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == ' ') {
        actualIndent++;
      } else if (char == '\t') {
        hasTab = true;
        if (strictMode) {
          return ValidationResult.error(
            'Tab characters not allowed in indentation (line $lineNumber)',
          );
        }
        actualIndent += 8; // Convert tab to 8 spaces
      } else {
        break;
      }
    }

    if (hasTab && !strictMode) {
      return ValidationResult.warning(
        'Tab characters in indentation are not recommended (line $lineNumber)',
      );
    }

    if (actualIndent != expectedIndent) {
      return ValidationResult.error(
        'Indentation mismatch on line $lineNumber: expected $expectedIndent, got $actualIndent',
      );
    }

    return ValidationResult.success();
  }

  /// Validate string escaping
  static ValidationResult validateStringEscaping(String value) {
    bool inEscape = false;
    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (inEscape) {
        if (!kUnescapeSequences.containsKey('\\$char')) {
          return ValidationResult.error('Invalid escape sequence: \\$char');
        }
        inEscape = false;
      } else if (char == '\\') {
        inEscape = true;
      }
    }

    if (inEscape) {
      return ValidationResult.error('Unterminated escape sequence');
    }

    return ValidationResult.success();
  }

  /// Validate number format according to TOON specification
  static ValidationResult validateNumber(
    String value, {
    bool strictMode = false,
  }) {
    if (value.isEmpty) {
      return ValidationResult.error('Empty number value');
    }

    // Check for leading zeros in strict mode
    if (strictMode && value.length > 1 && value.startsWith('0')) {
      if (value[1] != '.') {
        return ValidationResult.error(
          'Leading zeros not allowed in strict mode: $value',
        );
      }
    }

    // Try to parse as number
    final number = num.tryParse(value);
    if (number == null) {
      return ValidationResult.error('Invalid number format: $value');
    }

    // Check for exponential notation (not allowed in TOON)
    if (value.toLowerCase().contains('e')) {
      return ValidationResult.error('Exponential notation not allowed: $value');
    }

    return ValidationResult.success();
  }

  /// Validate boolean value
  static ValidationResult validateBoolean(String value) {
    final lower = value.toLowerCase().trim();
    if (lower != 'true' && lower != 'false') {
      return ValidationResult.error('Invalid boolean value: $value');
    }
    return ValidationResult.success();
  }

  /// Validate null value
  static ValidationResult validateNull(String value) {
    if (value.toLowerCase().trim() != 'null') {
      return ValidationResult.error('Invalid null value: $value');
    }
    return ValidationResult.success();
  }

  /// Validate object structure consistency
  static ValidationResult validateObjectStructure(Map<String, dynamic> object) {
    // Check for duplicate keys (should not happen in Map, but validate anyway)
    final keys = object.keys.toList();
    final uniqueKeys = keys.toSet();
    if (keys.length != uniqueKeys.length) {
      return ValidationResult.error('Duplicate keys found in object');
    }

    // Validate key names
    for (final key in keys) {
      if (!isValidKey(key)) {
        return ValidationResult.error('Invalid key: $key');
      }
    }

    return ValidationResult.success();
  }

  /// Validate array structure for tabular encoding
  static ValidationResult validateTabularArray(
    List<Map<String, dynamic>> array,
  ) {
    if (array.isEmpty) {
      return ValidationResult.success();
    }

    final firstKeys = array.first.keys.toSet();

    for (int i = 1; i < array.length; i++) {
      final currentKeys = array[i].keys.toSet();
      if (!_setsEqual(firstKeys, currentKeys)) {
        return ValidationResult.error(
          'Inconsistent object structure in tabular array at index $i',
        );
      }
    }

    return ValidationResult.success();
  }

  /// Check if two sets are equal
  static bool _setsEqual<T>(Set<T> set1, Set<T> set2) {
    return set1.length == set2.length && set1.containsAll(set2);
  }

  /// Validate TOON document structure
  static ValidationResult validateDocument(String source) {
    if (source.trim().isEmpty) {
      return ValidationResult.error('Empty TOON document');
    }

    final lines = source.split('\n');

    // Check for trailing whitespace
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.endsWith(' ') || line.endsWith('\t')) {
        return ValidationResult.warning('Trailing whitespace on line ${i + 1}');
      }
    }

    // Check for trailing newlines
    if (source.endsWith('\n')) {
      return ValidationResult.warning('Trailing newline at end of document');
    }

    return ValidationResult.success();
  }
}

/// Result of a validation operation
class ValidationResult {
  /// Create a validation result
  const ValidationResult._(this.severity, this.message);

  /// Create a successful validation result
  factory ValidationResult.success([String? message]) {
    return ValidationResult._(ToonErrorSeverity.info, message ?? 'Valid');
  }

  /// Create a warning validation result
  factory ValidationResult.warning(String message) {
    return ValidationResult._(ToonErrorSeverity.warning, message);
  }

  /// Create an error validation result
  factory ValidationResult.error(String message) {
    return ValidationResult._(ToonErrorSeverity.error, message);
  }

  /// The severity of the validation result
  final ToonErrorSeverity severity;

  /// The validation message
  final String message;

  /// Whether the validation was successful (no errors)
  bool get isSuccess => severity != ToonErrorSeverity.error;

  /// Whether the validation has warnings
  bool get hasWarnings => severity == ToonErrorSeverity.warning;

  /// Whether the validation has errors
  bool get hasErrors => severity == ToonErrorSeverity.error;

  @override
  String toString() => '${severity.name.toUpperCase()}: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          severity == other.severity &&
          message == other.message;

  @override
  int get hashCode => severity.hashCode ^ message.hashCode;
}
