/// TOON format constants and defaults
library;

/// Default indentation for TOON format (2 spaces)
const int kDefaultIndent = 2;

/// Default delimiter for TOON arrays
const String kDefaultDelimiter = ',';

/// TOON format version
const String kToonVersion = '2.0';

/// Maximum depth for nested objects to prevent infinite recursion
const int kMaxDepth = 100;

/// Default encoding for TOON strings
const String kDefaultEncoding = 'utf-8';

/// TOON line ending (always LF as per spec)
const String kLineEnding = '\n';

/// Characters that require quoting in TOON format
const Set<String> kStructuralChars = {
  ':', // Key-value separator
  '[', // Array length start
  ']', // Array length end
  '{', // Field list start
  '}', // Field list end
  '-', // List item marker
  '\n', // Line separator
  '\r', // Carriage return
  '\t', // Tab
};

/// Escape sequences allowed in TOON
const Map<String, String> kEscapeSequences = {
  '\\': '\\\\',
  '"': '\\"',
  '\n': '\\n',
  '\r': '\\r',
  '\t': '\\t',
};

/// Reverse mapping for unescape sequences
const Map<String, String> kUnescapeSequences = {
  '\\\\': '\\',
  '\\"': '"',
  '\\n': '\n',
  '\\r': '\r',
  '\\t': '\t',
};

/// TOON delimiter types
enum ToonDelimiter {
  /// Comma delimiter (default)
  comma(','),

  /// Tab delimiter
  tab('\t'),

  /// Pipe delimiter
  pipe('|');

  const ToonDelimiter(this.symbol);

  /// The actual delimiter character
  final String symbol;

  @override
  String toString() => symbol;
}

/// Key folding strategies for TOON encoding
enum ToonKeyFolding {
  /// No key folding (default)
  none,

  /// Safe key folding (only when no conflicts)
  safe,

  /// Aggressive key folding (force folding)
  aggressive,
}

/// TOON array encoding strategies
enum ToonArrayStrategy {
  /// Auto-detect based on content (default)
  auto,

  /// Force inline encoding
  inline,

  /// Force tabular encoding for objects
  tabular,

  /// Force list encoding
  list,
}

/// Validation levels for TOON parsing
enum ToonValidationLevel {
  /// No validation
  none,

  /// Basic validation (default)
  basic,

  /// Strict validation (full spec compliance)
  strict,
}

/// Error severity levels
enum ToonErrorSeverity {
  /// Information level
  info,

  /// Warning level
  warning,

  /// Error level
  error,

  /// Critical error level
  critical,
}
