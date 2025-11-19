/// String utility functions for TOON processing
library;

/// Utility functions for string processing in TOON format
class StringUtils {
  StringUtils._();

  /// Check if a string is quoted
  static bool isQuoted(String value) {
    return value.length >= 2 && value.startsWith('"') && value.endsWith('"');
  }

  /// Remove quotes from a string if present
  static String unquote(String value) {
    if (isQuoted(value)) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  /// Add quotes to a string
  static String quote(String value) {
    return '"$value"';
  }

  /// Trim whitespace from string
  static String trimSafely(String? value) {
    return value?.trim() ?? '';
  }

  /// Check if string is empty or whitespace
  static bool isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not empty and not whitespace
  static bool isNotBlank(String? value) {
    return !isBlank(value);
  }

  /// Capitalize first letter of string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Convert string to camelCase
  static String toCamelCase(String value) {
    final words = value.split(RegExp(r'[-_\s]+'));
    if (words.isEmpty) return value;

    final first = words.first.toLowerCase();
    final rest = words.skip(1).map(capitalize).join();
    return first + rest;
  }

  /// Convert string to snake_case
  static String toSnakeCase(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'^_'), '')
        .toLowerCase();
  }

  /// Count occurrences of substring in string
  static int countOccurrences(String text, String pattern) {
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(pattern, index)) != -1) {
      count++;
      index += pattern.length;
    }
    return count;
  }

  /// Replace all occurrences with case sensitivity option
  static String replaceAll(
    String text,
    String from,
    String to, {
    bool caseSensitive = true,
  }) {
    if (caseSensitive) {
      return text.replaceAll(from, to);
    } else {
      return text.replaceAll(
        RegExp(RegExp.escape(from), caseSensitive: false),
        to,
      );
    }
  }

  /// Split string into lines and handle different line endings
  static List<String> splitLines(String text) {
    return text.split(RegExp(r'\r?\n'));
  }

  /// Join lines with platform-appropriate line endings
  static String joinLines(List<String> lines, {String lineEnding = '\n'}) {
    return lines.join(lineEnding);
  }

  /// Indent each line of text
  static String indentLines(String text, int spaces) {
    final indent = ' ' * spaces;
    return splitLines(
      text,
    ).map((line) => line.isEmpty ? line : indent + line).join('\n');
  }

  /// Remove common leading whitespace from all lines
  static String dedent(String text) {
    final lines = splitLines(text);
    if (lines.isEmpty) return text;

    // Find minimum indentation (excluding empty lines)
    int minIndent = double.maxFinite.toInt();
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        final indent = line.length - line.trimLeft().length;
        if (indent < minIndent) {
          minIndent = indent;
        }
      }
    }

    if (minIndent == 0 || minIndent == double.maxFinite) {
      return text;
    }

    // Remove common indentation
    return lines
        .map(
          (line) => line.length >= minIndent ? line.substring(minIndent) : line,
        )
        .join('\n');
  }

  /// Pad string to specified length
  static String padLeft(String text, int length, [String padding = ' ']) {
    if (text.length >= length) return text;
    final padLength = length - text.length;
    final fullPads = padLength ~/ padding.length;
    final remainder = padLength % padding.length;
    return (padding * fullPads) + padding.substring(0, remainder) + text;
  }

  /// Pad string to specified length on the right
  static String padRight(String text, int length, [String padding = ' ']) {
    if (text.length >= length) return text;
    final padLength = length - text.length;
    final fullPads = padLength ~/ padding.length;
    final remainder = padLength % padding.length;
    return text + (padding * fullPads) + padding.substring(0, remainder);
  }

  /// Truncate string to maximum length with ellipsis
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    if (maxLength <= ellipsis.length) return ellipsis.substring(0, maxLength);
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Check if string contains only ASCII characters
  static bool isAscii(String text) {
    return text.codeUnits.every((unit) => unit >= 0 && unit <= 127);
  }

  /// Escape string for safe inclusion in error messages
  static String escapeForDisplay(String text, {int maxLength = 50}) {
    final escaped = text
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('"', '\\"');
    return truncate(escaped, maxLength);
  }
}
