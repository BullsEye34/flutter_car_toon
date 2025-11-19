/// Base converter system for TOON encoding/decoding
library;

import 'toon_options.dart';
import 'toon_error.dart';

/// Abstract base class for TOON type converters
abstract class ToonConverter<T> {
  /// Creates a new TOON converter
  const ToonConverter();

  /// Check if this converter can handle the given object
  bool canConvert(Object? object) => object is T;

  /// Check if this converter can handle the given type
  bool canConvertType(Type type) => type == T;

  /// Encode an object to TOON representation
  ///
  /// Returns the TOON representation as a string, or null if the object
  /// should be handled by the default encoder.
  String? encode(T object, ToonOptions options);

  /// Decode a TOON string representation to the target type
  ///
  /// Throws [ToonDecodingError] if the value cannot be decoded.
  T decode(String value, ToonOptions options);

  /// Get the priority of this converter (higher = more priority)
  /// Used when multiple converters can handle the same type
  int get priority => 0;
}

/// Registry for managing TOON converters
class ToonConverterRegistry {
  /// Creates a new converter registry
  ToonConverterRegistry() {
    _registerDefaultConverters();
  }

  final Map<Type, ToonConverter> _converters = {};
  final List<ToonConverter> _genericConverters = [];

  /// Register a converter for a specific type
  void register<T>(ToonConverter<T> converter) {
    _converters[T] = converter;
  }

  /// Register a generic converter that handles multiple types
  void registerGeneric(ToonConverter converter) {
    _genericConverters.add(converter);
    _genericConverters.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Unregister a converter for a specific type
  void unregister<T>() {
    _converters.remove(T);
  }

  /// Unregister a generic converter
  void unregisterGeneric(ToonConverter converter) {
    _genericConverters.remove(converter);
  }

  /// Get a converter for the given object
  ToonConverter? getConverter(Object? object) {
    if (object == null) return null;

    // Check type-specific converters first
    final typeConverter = _converters[object.runtimeType];
    if (typeConverter != null && typeConverter.canConvert(object)) {
      return typeConverter;
    }

    // Check generic converters
    for (final converter in _genericConverters) {
      if (converter.canConvert(object)) {
        return converter;
      }
    }

    return null;
  }

  /// Get a converter for the given type
  ToonConverter? getConverterForType(Type type) {
    // Check type-specific converters first
    final typeConverter = _converters[type];
    if (typeConverter != null) {
      return typeConverter;
    }

    // Check generic converters
    for (final converter in _genericConverters) {
      if (converter.canConvertType(type)) {
        return converter;
      }
    }

    return null;
  }

  /// Get all registered converters
  List<ToonConverter> get allConverters {
    return [..._converters.values, ..._genericConverters];
  }

  /// Clear all converters
  void clear() {
    _converters.clear();
    _genericConverters.clear();
  }

  /// Register default built-in converters
  void _registerDefaultConverters() {
    // Built-in converters will be registered here
    // This is implemented by specific converter classes
  }

  /// Create a copy of this registry
  ToonConverterRegistry copy() {
    final copy = ToonConverterRegistry();
    copy._converters.addAll(_converters);
    copy._genericConverters.addAll(_genericConverters);
    return copy;
  }
}

/// Global converter registry instance
final globalToonConverterRegistry = ToonConverterRegistry();

/// Simple string converter (pass-through for strings)
class StringToonConverter extends ToonConverter<String> {
  const StringToonConverter();

  @override
  String? encode(String object, ToonOptions options) {
    // Let the default encoder handle string quoting and escaping
    return null;
  }

  @override
  String decode(String value, ToonOptions options) {
    return value;
  }
}

/// Number converter for int and double
class NumberToonConverter extends ToonConverter<num> {
  const NumberToonConverter();

  @override
  bool canConvert(Object? object) => object is num;

  @override
  bool canConvertType(Type type) =>
      type == num || type == int || type == double;

  @override
  String? encode(num object, ToonOptions options) {
    // Handle special values
    if (object.isNaN || object.isInfinite) {
      return 'null'; // Convert NaN/Infinity to null as per spec
    }

    // Handle negative zero
    if (object == 0 && object.isNegative) {
      return '0'; // Convert -0 to 0 as per spec
    }

    // Use canonical decimal representation (no exponential notation)
    if (object is double) {
      final str = object.toString();
      if (str.contains('e') || str.contains('E')) {
        // Convert scientific notation to decimal
        return object
            .toStringAsFixed(object.truncate() == object ? 0 : 10)
            .replaceAll(RegExp(r'\.?0+$'), '');
      }
      return str;
    }

    return object.toString();
  }

  @override
  num decode(String value, ToonOptions options) {
    final trimmed = value.trim();

    // Try parsing as int first
    final intValue = int.tryParse(trimmed);
    if (intValue != null) return intValue;

    // Try parsing as double
    final doubleValue = double.tryParse(trimmed);
    if (doubleValue != null) return doubleValue;

    throw ToonConversionError(
      'Cannot parse \'$value\' as a number',
      sourceType: String,
      targetType: num,
      value: value,
    );
  }
}

/// Boolean converter
class BooleanToonConverter extends ToonConverter<bool> {
  const BooleanToonConverter();

  @override
  String? encode(bool object, ToonOptions options) {
    return object ? 'true' : 'false';
  }

  @override
  bool decode(String value, ToonOptions options) {
    final trimmed = value.trim().toLowerCase();
    switch (trimmed) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        throw ToonConversionError(
          'Cannot parse \'$value\' as a boolean',
          sourceType: String,
          targetType: bool,
          value: value,
        );
    }
  }
}

/// Null converter
class NullToonConverter extends ToonConverter<Null> {
  const NullToonConverter();

  @override
  bool canConvert(Object? object) => object == null;

  @override
  String? encode(Null object, ToonOptions options) {
    return 'null';
  }

  @override
  Null decode(String value, ToonOptions options) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed == 'null') {
      return null;
    }

    throw ToonConversionError(
      'Cannot parse \'$value\' as null',
      sourceType: String,
      targetType: Null,
      value: value,
    );
  }
}
