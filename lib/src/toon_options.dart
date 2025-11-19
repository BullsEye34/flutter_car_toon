/// TOON encoding and decoding options
library;

import 'constants.dart';

/// Configuration options for TOON encoding and decoding
class ToonOptions {
  /// Creates TOON options with the specified configuration
  const ToonOptions({
    this.indent = kDefaultIndent,
    this.delimiter = ToonDelimiter.comma,
    this.keyFolding = ToonKeyFolding.none,
    this.arrayStrategy = ToonArrayStrategy.auto,
    this.validationLevel = ToonValidationLevel.basic,
    this.maxDepth = kMaxDepth,
    this.strictMode = false,
    this.preserveOrder = true,
    this.allowTrailingCommas = false,
    this.compactOutput = false,
    this.allowComments = false,
    this.dateTimeFormat,
    this.customConverters = const {},
  });

  /// Number of spaces for indentation (default: 2)
  final int indent;

  /// Delimiter for array elements
  final ToonDelimiter delimiter;

  /// Key folding strategy for nested objects
  final ToonKeyFolding keyFolding;

  /// Array encoding strategy
  final ToonArrayStrategy arrayStrategy;

  /// Validation level for parsing
  final ToonValidationLevel validationLevel;

  /// Maximum nesting depth to prevent infinite recursion
  final int maxDepth;

  /// Enable strict TOON specification compliance
  final bool strictMode;

  /// Preserve object key order during encoding/decoding
  final bool preserveOrder;

  /// Allow trailing commas in arrays (non-standard extension)
  final bool allowTrailingCommas;

  /// Produce compact output without extra whitespace
  final bool compactOutput;

  /// Allow comments in TOON format (non-standard extension)
  final bool allowComments;

  /// Custom DateTime format string (null = ISO 8601)
  final String? dateTimeFormat;

  /// Custom type converters for encoding/decoding
  final Map<Type, dynamic> customConverters;

  /// Create a copy of options with modified values
  ToonOptions copyWith({
    int? indent,
    ToonDelimiter? delimiter,
    ToonKeyFolding? keyFolding,
    ToonArrayStrategy? arrayStrategy,
    ToonValidationLevel? validationLevel,
    int? maxDepth,
    bool? strictMode,
    bool? preserveOrder,
    bool? allowTrailingCommas,
    bool? compactOutput,
    bool? allowComments,
    String? dateTimeFormat,
    Map<Type, dynamic>? customConverters,
  }) {
    return ToonOptions(
      indent: indent ?? this.indent,
      delimiter: delimiter ?? this.delimiter,
      keyFolding: keyFolding ?? this.keyFolding,
      arrayStrategy: arrayStrategy ?? this.arrayStrategy,
      validationLevel: validationLevel ?? this.validationLevel,
      maxDepth: maxDepth ?? this.maxDepth,
      strictMode: strictMode ?? this.strictMode,
      preserveOrder: preserveOrder ?? this.preserveOrder,
      allowTrailingCommas: allowTrailingCommas ?? this.allowTrailingCommas,
      compactOutput: compactOutput ?? this.compactOutput,
      allowComments: allowComments ?? this.allowComments,
      dateTimeFormat: dateTimeFormat ?? this.dateTimeFormat,
      customConverters: customConverters ?? this.customConverters,
    );
  }

  /// Default TOON options
  static const ToonOptions defaults = ToonOptions();

  /// Strict TOON specification compliance options
  static const ToonOptions strict = ToonOptions(
    strictMode: true,
    validationLevel: ToonValidationLevel.strict,
    allowTrailingCommas: false,
    allowComments: false,
  );

  /// Compact encoding options for minimal output size
  static const ToonOptions compact = ToonOptions(
    compactOutput: true,
    delimiter: ToonDelimiter.comma,
    keyFolding: ToonKeyFolding.safe,
  );

  /// Pretty printing options for human-readable output
  static const ToonOptions pretty = ToonOptions(
    indent: 4,
    compactOutput: false,
    arrayStrategy: ToonArrayStrategy.auto,
  );

  /// Performance-optimized options for large datasets
  static const ToonOptions performance = ToonOptions(
    validationLevel: ToonValidationLevel.none,
    preserveOrder: false,
    maxDepth: 50,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToonOptions &&
          runtimeType == other.runtimeType &&
          indent == other.indent &&
          delimiter == other.delimiter &&
          keyFolding == other.keyFolding &&
          arrayStrategy == other.arrayStrategy &&
          validationLevel == other.validationLevel &&
          maxDepth == other.maxDepth &&
          strictMode == other.strictMode &&
          preserveOrder == other.preserveOrder &&
          allowTrailingCommas == other.allowTrailingCommas &&
          compactOutput == other.compactOutput &&
          allowComments == other.allowComments &&
          dateTimeFormat == other.dateTimeFormat;

  @override
  int get hashCode =>
      indent.hashCode ^
      delimiter.hashCode ^
      keyFolding.hashCode ^
      arrayStrategy.hashCode ^
      validationLevel.hashCode ^
      maxDepth.hashCode ^
      strictMode.hashCode ^
      preserveOrder.hashCode ^
      allowTrailingCommas.hashCode ^
      compactOutput.hashCode ^
      allowComments.hashCode ^
      dateTimeFormat.hashCode;

  @override
  String toString() {
    return 'ToonOptions('
        'indent: $indent, '
        'delimiter: $delimiter, '
        'keyFolding: $keyFolding, '
        'arrayStrategy: $arrayStrategy, '
        'validationLevel: $validationLevel, '
        'maxDepth: $maxDepth, '
        'strictMode: $strictMode, '
        'preserveOrder: $preserveOrder, '
        'allowTrailingCommas: $allowTrailingCommas, '
        'compactOutput: $compactOutput, '
        'allowComments: $allowComments, '
        'dateTimeFormat: $dateTimeFormat'
        ')';
  }
}
