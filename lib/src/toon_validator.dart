/// TOON validator for comprehensive format validation
library;

import 'toon_options.dart';
import 'toon_error.dart';
import 'constants.dart';
import 'utils/validation_utils.dart';

/// Comprehensive TOON format validator
class ToonValidator {
  /// Create a new TOON validator with the given options
  ToonValidator({ToonOptions? options})
    : _options = options ?? ToonOptions.defaults;

  final ToonOptions _options;

  /// Validate a TOON document and return all issues found
  List<ToonError> validate(String source) {
    final errors = <ToonError>[];

    try {
      // Basic document validation
      final docResult = ValidationUtils.validateDocument(source);
      if (docResult.hasErrors) {
        errors.add(
          ToonValidationError(
            docResult.message,
            severity: ToonErrorSeverity.error,
            source: source,
          ),
        );
      } else if (docResult.hasWarnings) {
        errors.add(
          ToonValidationError(
            docResult.message,
            severity: ToonErrorSeverity.warning,
            source: source,
          ),
        );
      }

      // Parse and validate structure
      final structureErrors = _validateStructure(source);
      errors.addAll(structureErrors);
    } catch (e) {
      errors.add(
        ToonValidationError(
          'Validation failed: ${e.toString()}',
          severity: ToonErrorSeverity.critical,
          source: source,
        ),
      );
    }

    return errors;
  }

  /// Validate the structure of a TOON document
  List<ToonError> _validateStructure(String source) {
    final errors = <ToonError>[];
    final lines = source.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;

      // Skip empty lines and comments
      if (_isEmptyOrComment(line)) continue;

      // Validate indentation
      final indentResult = _validateLineIndentation(line, lineNumber);
      if (indentResult.hasErrors || indentResult.hasWarnings) {
        errors.add(
          ToonValidationError(
            indentResult.message,
            severity: indentResult.hasErrors
                ? ToonErrorSeverity.error
                : ToonErrorSeverity.warning,
            line: lineNumber,
            source: source,
          ),
        );
      }

      // Validate syntax
      final syntaxErrors = _validateLineSyntax(line, lineNumber, source);
      errors.addAll(syntaxErrors);
    }

    return errors;
  }

  /// Validate indentation for a single line
  ValidationResult _validateLineIndentation(String line, int lineNumber) {
    int indent = 0;
    bool hasTab = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == ' ') {
        indent++;
      } else if (char == '\t') {
        hasTab = true;
        if (_options.strictMode) {
          return ValidationResult.error(
            'Tab characters not allowed in strict mode (line $lineNumber)',
          );
        }
        indent += 8; // Convert tab to spaces
      } else {
        break;
      }
    }

    if (hasTab && !_options.strictMode) {
      return ValidationResult.warning(
        'Tab characters in indentation not recommended (line $lineNumber)',
      );
    }

    // In a full validator, we would track expected indentation levels
    // For now, just validate that indentation is consistent with options
    if (indent % _options.indent != 0) {
      return ValidationResult.error(
        'Inconsistent indentation on line $lineNumber: expected multiple of ${_options.indent}',
      );
    }

    return ValidationResult.success();
  }

  /// Validate syntax for a single line
  List<ToonError> _validateLineSyntax(
    String line,
    int lineNumber,
    String source,
  ) {
    final errors = <ToonError>[];
    final content = line.trim();

    if (content.isEmpty) return errors;

    // Check for array headers
    if (content.startsWith('[')) {
      final headerResult = ValidationUtils.validateArrayHeader(content);
      if (headerResult.hasErrors) {
        errors.add(
          ToonSyntaxError(
            headerResult.message,
            line: lineNumber,
            source: source,
            actualValue: content,
          ),
        );
      } else if (headerResult.hasWarnings) {
        errors.add(
          ToonValidationError(
            headerResult.message,
            severity: ToonErrorSeverity.warning,
            line: lineNumber,
            source: source,
          ),
        );
      }
      return errors;
    }

    // Check for key-value pairs
    final colonIndex = _findUnquotedColon(content);
    if (colonIndex != -1) {
      final key = content.substring(0, colonIndex).trim();
      final value = content.substring(colonIndex + 1).trim();

      // Validate key
      if (!ValidationUtils.isValidKey(_unquoteIfNeeded(key))) {
        errors.add(
          ToonValidationError(
            'Invalid key format: $key',
            line: lineNumber,
            source: source,
            violatedRule: 'key-format',
          ),
        );
      }

      // Validate value if present
      if (value.isNotEmpty) {
        final valueErrors = _validateValue(value, lineNumber, source);
        errors.addAll(valueErrors);
      }
    } else {
      // Line should be a primitive value or list item
      if (content.startsWith('-')) {
        // List item - validate the value part
        final value = content.substring(1).trim();
        if (value.isNotEmpty) {
          final valueErrors = _validateValue(value, lineNumber, source);
          errors.addAll(valueErrors);
        }
      } else {
        // Should be a primitive value
        final valueErrors = _validateValue(content, lineNumber, source);
        errors.addAll(valueErrors);
      }
    }

    return errors;
  }

  /// Validate a value string
  List<ToonError> _validateValue(String value, int lineNumber, String source) {
    final errors = <ToonError>[];

    // Skip validation for array headers
    if (value.startsWith('[')) return errors;

    // Check quoted strings
    if (value.startsWith('"') && value.endsWith('"')) {
      final stringResult = ValidationUtils.validateStringEscaping(
        value.substring(1, value.length - 1),
      );
      if (stringResult.hasErrors) {
        errors.add(
          ToonSyntaxError(
            stringResult.message,
            line: lineNumber,
            source: source,
            actualValue: value,
          ),
        );
      }
      return errors;
    }

    // Check unquoted primitives
    final lower = value.toLowerCase();

    // Boolean values
    if (lower == 'true' || lower == 'false') {
      final boolResult = ValidationUtils.validateBoolean(value);
      if (boolResult.hasErrors) {
        errors.add(
          ToonValidationError(
            boolResult.message,
            line: lineNumber,
            source: source,
          ),
        );
      }
      return errors;
    }

    // Null value
    if (lower == 'null') {
      final nullResult = ValidationUtils.validateNull(value);
      if (nullResult.hasErrors) {
        errors.add(
          ToonValidationError(
            nullResult.message,
            line: lineNumber,
            source: source,
          ),
        );
      }
      return errors;
    }

    // Number values
    if (num.tryParse(value) != null) {
      final numberResult = ValidationUtils.validateNumber(
        value,
        strictMode: _options.strictMode,
      );
      if (numberResult.hasErrors) {
        errors.add(
          ToonValidationError(
            numberResult.message,
            line: lineNumber,
            source: source,
          ),
        );
      } else if (numberResult.hasWarnings) {
        errors.add(
          ToonValidationError(
            numberResult.message,
            severity: ToonErrorSeverity.warning,
            line: lineNumber,
            source: source,
          ),
        );
      }
      return errors;
    }

    // If we get here, it's an unquoted string - validate it doesn't need quoting
    if (_needsQuoting(value)) {
      errors.add(
        ToonValidationError(
          'Unquoted string contains characters that require quoting: $value',
          line: lineNumber,
          source: source,
          suggestion: 'Quote the string or escape special characters',
        ),
      );
    }

    return errors;
  }

  /// Find unquoted colon in a string
  int _findUnquotedColon(String value) {
    bool inQuotes = false;
    bool escaped = false;

    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }

      if (!inQuotes && char == ':') {
        return i;
      }
    }

    return -1;
  }

  /// Check if a line is empty or a comment
  bool _isEmptyOrComment(String line) {
    final trimmed = line.trim();
    return trimmed.isEmpty ||
        (_options.allowComments && trimmed.startsWith('#'));
  }

  /// Remove quotes from a string if present
  String _unquoteIfNeeded(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2 &&
        trimmed.startsWith('"') &&
        trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Check if a string needs quoting
  bool _needsQuoting(String value) {
    if (value.isEmpty) return true;

    // Check for structural characters
    for (final char in kStructuralChars) {
      if (value.contains(char)) return true;
    }

    // Check for delimiter
    if (value.contains(_options.delimiter.symbol)) return true;

    // Check for leading/trailing whitespace
    if (value.trim() != value) return true;

    return false;
  }

  /// Quick validation check (returns true if valid, false if invalid)
  bool isValid(String source) {
    final errors = validate(source);
    return !errors.any(
      (error) =>
          error.severity == ToonErrorSeverity.error ||
          error.severity == ToonErrorSeverity.critical,
    );
  }

  /// Get only error-level issues (excluding warnings)
  List<ToonError> getErrors(String source) {
    final errors = validate(source);
    return errors
        .where(
          (error) =>
              error.severity == ToonErrorSeverity.error ||
              error.severity == ToonErrorSeverity.critical,
        )
        .toList();
  }

  /// Get only warning-level issues
  List<ToonError> getWarnings(String source) {
    final errors = validate(source);
    return errors
        .where((error) => error.severity == ToonErrorSeverity.warning)
        .toList();
  }
}
