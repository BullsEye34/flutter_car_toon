/// Annotation for customizing TOON field serialization
library;

/// Annotation to customize how a field is serialized in TOON format
class ToonField {
  /// Create a TOON field annotation
  const ToonField({
    this.name,
    this.include = true,
    this.includeIfNull = true,
    this.converter,
  });

  /// Custom name for the field in TOON output
  final String? name;

  /// Whether to include this field in serialization
  final bool include;

  /// Whether to include the field if its value is null
  final bool includeIfNull;

  /// Custom converter for this field
  final Type? converter;
}
