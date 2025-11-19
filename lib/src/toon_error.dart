/// TOON error handling and exceptions
library;

import 'constants.dart';

/// Base class for all TOON-related errors
abstract class ToonError implements Exception {
  /// Creates a TOON error with the given message and optional details
  const ToonError(
    this.message, {
    this.severity = ToonErrorSeverity.error,
    this.line,
    this.column,
    this.offset,
    this.source,
    this.context,
  });

  /// Error message describing what went wrong
  final String message;

  /// Severity level of the error
  final ToonErrorSeverity severity;

  /// Line number where the error occurred (1-based)
  final int? line;

  /// Column number where the error occurred (1-based)
  final int? column;

  /// Character offset where the error occurred (0-based)
  final int? offset;

  /// Source text where the error occurred
  final String? source;

  /// Additional context about the error
  final Map<String, dynamic>? context;

  /// Get location information as a formatted string
  String get location {
    if (line != null && column != null) {
      return 'line $line, column $column';
    } else if (line != null) {
      return 'line $line';
    } else if (offset != null) {
      return 'offset $offset';
    } else {
      return 'unknown location';
    }
  }

  /// Get the source excerpt around the error location
  String? get sourceExcerpt {
    if (source == null || line == null) return null;

    final lines = source!.split('\n');
    if (line! > lines.length) return null;

    final errorLine = lines[line! - 1];
    final buffer = StringBuffer();

    // Add context lines before
    if (line! > 1) {
      buffer.writeln('${line! - 1}: ${lines[line! - 2]}');
    }

    // Add error line with pointer
    buffer.writeln('$line: $errorLine');
    if (column != null && column! <= errorLine.length) {
      buffer.writeln(' ' * (line.toString().length + 2 + column! - 1) + '^');
    }

    // Add context lines after
    if (line! < lines.length) {
      buffer.writeln('${line! + 1}: ${lines[line!]}');
    }

    return buffer.toString().trimRight();
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');

    if (line != null || column != null || offset != null) {
      buffer.write(' at $location');
    }

    final excerpt = sourceExcerpt;
    if (excerpt != null) {
      buffer.write('\n\n$excerpt');
    }

    if (context != null && context!.isNotEmpty) {
      buffer.write('\n\nContext: $context');
    }

    return buffer.toString();
  }
}

/// Error that occurs during TOON encoding
class ToonEncodingError extends ToonError {
  /// Creates a TOON encoding error
  const ToonEncodingError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    this.object,
    this.path,
  });

  /// The object that failed to encode
  final Object? object;

  /// The path to the object that failed (e.g., 'user.profile.name')
  final List<String>? path;

  /// Get a human-readable path string
  String? get pathString => path?.join('.');
}

/// Error that occurs during TOON decoding/parsing
class ToonDecodingError extends ToonError {
  /// Creates a TOON decoding error
  const ToonDecodingError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    this.expectedType,
    this.actualValue,
  });

  /// The expected type that failed to parse
  final Type? expectedType;

  /// The actual value that was encountered
  final String? actualValue;
}

/// Error that occurs during TOON validation
class ToonValidationError extends ToonError {
  /// Creates a TOON validation error
  const ToonValidationError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    this.violatedRule,
    this.suggestion,
  });

  /// The validation rule that was violated
  final String? violatedRule;

  /// Suggestion for fixing the error
  final String? suggestion;
}

/// Error that occurs due to syntax issues in TOON format
class ToonSyntaxError extends ToonDecodingError {
  /// Creates a TOON syntax error
  const ToonSyntaxError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    super.expectedType,
    super.actualValue,
    this.unexpectedToken,
    this.expectedTokens,
  });

  /// The unexpected token that was encountered
  final String? unexpectedToken;

  /// List of tokens that were expected instead
  final List<String>? expectedTokens;
}

/// Error that occurs when TOON structure is invalid
class ToonStructureError extends ToonDecodingError {
  /// Creates a TOON structure error
  const ToonStructureError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    super.expectedType,
    super.actualValue,
    this.structureType,
  });

  /// The type of structure that was invalid (e.g., 'array', 'object')
  final String? structureType;
}

/// Error that occurs when array lengths don't match
class ToonArrayLengthError extends ToonStructureError {
  /// Creates a TOON array length error
  const ToonArrayLengthError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    super.expectedType,
    super.actualValue,
    required this.declaredLength,
    required this.actualLength,
  }) : super(structureType: 'array');

  /// The length declared in the array header
  final int declaredLength;

  /// The actual number of items found
  final int actualLength;
}

/// Error that occurs when indentation is invalid
class ToonIndentationError extends ToonSyntaxError {
  /// Creates a TOON indentation error
  const ToonIndentationError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    super.expectedType,
    super.actualValue,
    super.unexpectedToken,
    super.expectedTokens,
    this.expectedIndent,
    this.actualIndent,
  });

  /// The expected indentation level
  final int? expectedIndent;

  /// The actual indentation level found
  final int? actualIndent;
}

/// Error that occurs when conversion between types fails
class ToonConversionError extends ToonError {
  /// Creates a TOON conversion error
  const ToonConversionError(
    super.message, {
    super.severity,
    super.line,
    super.column,
    super.offset,
    super.source,
    super.context,
    required this.sourceType,
    required this.targetType,
    this.value,
  });

  /// The source type being converted from
  final Type sourceType;

  /// The target type being converted to
  final Type targetType;

  /// The value that failed to convert
  final dynamic value;
}

/// Utility class for creating common TOON errors
class ToonErrors {
  ToonErrors._();

  /// Create an unexpected end of input error
  static ToonSyntaxError unexpectedEndOfInput({
    int? line,
    int? column,
    int? offset,
    String? source,
  }) {
    return ToonSyntaxError(
      'Unexpected end of input',
      line: line,
      column: column,
      offset: offset,
      source: source,
      expectedTokens: ['key', 'value', 'array element'],
    );
  }

  /// Create an invalid character error
  static ToonSyntaxError invalidCharacter(
    String char, {
    int? line,
    int? column,
    int? offset,
    String? source,
  }) {
    return ToonSyntaxError(
      'Invalid character: \'$char\'',
      line: line,
      column: column,
      offset: offset,
      source: source,
      unexpectedToken: char,
    );
  }

  /// Create an array length mismatch error
  static ToonArrayLengthError arrayLengthMismatch(
    int declared,
    int actual, {
    int? line,
    int? column,
    int? offset,
    String? source,
  }) {
    return ToonArrayLengthError(
      'Array length mismatch: declared $declared, found $actual',
      line: line,
      column: column,
      offset: offset,
      source: source,
      declaredLength: declared,
      actualLength: actual,
    );
  }

  /// Create an indentation error
  static ToonIndentationError invalidIndentation(
    int expected,
    int actual, {
    int? line,
    int? column,
    int? offset,
    String? source,
  }) {
    return ToonIndentationError(
      'Invalid indentation: expected $expected spaces, found $actual',
      line: line,
      column: column,
      offset: offset,
      source: source,
      expectedIndent: expected,
      actualIndent: actual,
    );
  }

  /// Create a type conversion error
  static ToonConversionError conversionError(
    Type sourceType,
    Type targetType,
    dynamic value, {
    int? line,
    int? column,
    int? offset,
    String? source,
  }) {
    return ToonConversionError(
      'Cannot convert ${sourceType.toString()} to ${targetType.toString()}: $value',
      sourceType: sourceType,
      targetType: targetType,
      value: value,
      line: line,
      column: column,
      offset: offset,
      source: source,
    );
  }
}
