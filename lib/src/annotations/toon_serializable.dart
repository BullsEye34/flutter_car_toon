/// Annotation for TOON serializable classes
library;

/// Annotation to mark classes for TOON code generation
class ToonSerializable {
  /// Create a TOON serializable annotation
  const ToonSerializable({
    this.createFactory = true,
    this.createToToon = true,
    this.includeIfNull = true,
    this.explicitToToon = false,
  });

  /// Whether to generate a fromToon factory constructor
  final bool createFactory;

  /// Whether to generate a toToon method
  final bool createToToon;

  /// Whether to include fields with null values
  final bool includeIfNull;

  /// Whether to require explicit toToon calls for nested objects
  final bool explicitToToon;
}
