/// Utility functions for TOON format processing
library;

/// Utility functions for TOON processing
class ToonUtils {
  ToonUtils._();

  /// Check if a string needs to be quoted in TOON format
  static bool needsQuoting(String value, {String delimiter = ','}) {
    if (value.isEmpty) return true;

    // Check for structural characters
    const structuralChars = {':', '[', ']', '{', '}', '-', '\n', '\r', '\t'};
    for (final char in structuralChars) {
      if (value.contains(char)) return true;
    }

    // Check for delimiter
    if (value.contains(delimiter)) return true;

    // Check for leading/trailing whitespace
    if (value.trim() != value) return true;

    // Check if it looks like a boolean, number, or null
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == 'false' || lower == 'null') return true;
    if (num.tryParse(value) != null) return true;

    return false;
  }

  /// Escape a string for TOON format
  static String escapeString(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final char = value[i];
      switch (char) {
        case '\\':
          buffer.write('\\\\');
          break;
        case '"':
          buffer.write('\\"');
          break;
        case '\n':
          buffer.write('\\n');
          break;
        case '\r':
          buffer.write('\\r');
          break;
        case '\t':
          buffer.write('\\t');
          break;
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Unescape a string from TOON format
  static String unescapeString(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (value[i] == '\\' && i + 1 < value.length) {
        final next = value[i + 1];
        switch (next) {
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          default:
            buffer.write('\\');
            buffer.write(next);
        }
        i++; // Skip the next character
      } else {
        buffer.write(value[i]);
      }
    }
    return buffer.toString();
  }

  /// Normalize a number for TOON output (no exponential notation, handle special values)
  static String normalizeNumber(num value) {
    // Handle special values
    if (value.isNaN || value.isInfinite) {
      return 'null';
    }

    // Handle negative zero
    if (value == 0 && value.isNegative) {
      return '0';
    }

    // Use canonical decimal representation
    if (value is double) {
      final str = value.toString();
      if (str.contains('e') || str.contains('E')) {
        // Convert scientific notation to decimal
        final fixed = value.toStringAsFixed(value.truncate() == value ? 0 : 10);
        return fixed.replaceAll(RegExp(r'\.?0+$'), '');
      }
      return str;
    }

    return value.toString();
  }

  /// Parse a number from string with TOON rules
  static num? parseNumber(String value, {bool strictMode = false}) {
    final trimmed = value.trim();

    // Handle leading zeros in strict mode
    if (strictMode &&
        trimmed.length > 1 &&
        trimmed.startsWith('0') &&
        _isDigit(trimmed[1])) {
      return null; // Invalid in strict mode
    }

    // Try parsing as int first
    final intValue = int.tryParse(trimmed);
    if (intValue != null) return intValue;

    // Try parsing as double
    final doubleValue = double.tryParse(trimmed);
    return doubleValue;
  }

  /// Check if a character is a digit
  static bool _isDigit(String char) {
    return char.length == 1 && '0123456789'.contains(char);
  }

  /// Calculate indentation string
  static String getIndent(int level, int spaces) {
    return ' ' * (level * spaces);
  }

  /// Validate TOON array header format
  static bool isValidArrayHeader(String header) {
    final regex = RegExp(r'^\[(\d+)(?:([,\t|])(?:\{([^}]+)\})?)?\]:?');
    return regex.hasMatch(header.trim());
  }

  /// Extract array length from header
  static int? extractArrayLength(String header) {
    final regex = RegExp(r'^\[(\d+)');
    final match = regex.firstMatch(header.trim());
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// Check if two maps have the same keys (for tabular array detection)
  static bool haveSameKeys(
    Map<dynamic, dynamic> map1,
    Map<dynamic, dynamic> map2,
  ) {
    final keys1 = map1.keys.toSet();
    final keys2 = map2.keys.toSet();
    return keys1.length == keys2.length && keys1.containsAll(keys2);
  }

  /// Convert a path list to dot notation string
  static String pathToString(List<String> path) {
    return path.join('.');
  }

  /// Split string by delimiter, respecting quoted strings
  static List<String> smartSplit(String value, String delimiter) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    bool escaped = false;

    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }

      if (char == '\\') {
        buffer.write(char);
        escaped = true;
        continue;
      }

      if (char == '"') {
        inQuotes = !inQuotes;
        buffer.write(char);
        continue;
      }

      if (!inQuotes && char == delimiter) {
        result.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty || value.endsWith(delimiter)) {
      result.add(buffer.toString());
    }

    return result;
  }
}
