/// TOON code generator for @ToonSerializable annotation
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations/toon_serializable.dart';

/// Generator for classes annotated with @ToonSerializable
class ToonGenerator extends GeneratorForAnnotation<ToonSerializable> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSource(
        'Generator can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name!;
    final createFactory =
        annotation.read('createFactory').literalValue as bool? ?? true;
    final createToToon =
        annotation.read('createToToon').literalValue as bool? ?? true;
    final includeIfNull =
        annotation.read('includeIfNull').literalValue as bool? ?? false;
    final explicitToToon =
        annotation.read('explicitToToon').literalValue as bool? ?? false;

    final buffer = StringBuffer();

    // Generate extension for non-intrusive approach
    buffer.writeln('extension ${className}ToonExtension on $className {');

    // Generate toToon method
    if (createToToon) {
      buffer.writeln(_generateToToon(element, includeIfNull, explicitToToon));
    }

    buffer.writeln('}');

    // Generate fromToon factory
    if (createFactory) {
      buffer.writeln();
      buffer.writeln(_generateFromToon(element, className));
    }

    return buffer.toString();
  }

  /// Generate the toToon method
  String _generateToToon(
    ClassElement element,
    bool includeIfNull,
    bool explicitToToon,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  /// Convert this object to TOON map format');
    buffer.writeln('  Map<String, dynamic> toToon() {');
    buffer.writeln('    return {');

    for (final field in element.fields) {
      if (field.isStatic || field.isPrivate) continue;

      final fieldAnnotation = _getFieldAnnotation(field);
      if (fieldAnnotation != null && !fieldAnnotation['include']) {
        continue;
      }

      final fieldName = field.name;
      final toonName = fieldAnnotation?['name'] as String? ?? fieldName;
      final fieldIncludeIfNull =
          fieldAnnotation?['includeIfNull'] as bool? ?? includeIfNull;

      if (fieldIncludeIfNull) {
        buffer.write('      \'$toonName\': ');
        buffer.writeln('${_serializeField(field, explicitToToon)},');
      } else {
        buffer.writeln(
          '      if ($fieldName != null) \'$toonName\': '
          '${_serializeField(field, explicitToToon)},',
        );
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');
    return buffer.toString();
  }

  /// Serialize a field based on its type
  String _serializeField(FieldElement field, bool explicitToToon) {
    final fieldName = field.name!;
    final fieldType = field.type;

    // Check for custom converter
    final fieldAnnotation = _getFieldAnnotation(field);
    if (fieldAnnotation != null && fieldAnnotation['converter'] != null) {
      final converterType = fieldAnnotation['converter'];
      return 'const $converterType().toToon($fieldName)';
    }

    // Handle collections
    if (_isListType(fieldType)) {
      final elementType = (fieldType as InterfaceType).typeArguments.first;
      if (_isPrimitive(elementType)) {
        return fieldName;
      }
      // List of non-primitive objects - need to serialize each
      return '$fieldName?.map((e) => e.toToon()).toList()';
    }

    if (_isMapType(fieldType)) {
      return fieldName;
    }

    // Handle primitives
    if (_isPrimitive(fieldType)) {
      return fieldName;
    }

    // Handle nested objects - always call toToon() for non-primitives
    if (fieldType.nullabilitySuffix == NullabilitySuffix.question) {
      return '$fieldName?.toToon()';
    }
    return '$fieldName.toToon()';
  }

  /// Generate the fromToon factory
  String _generateFromToon(ClassElement element, String className) {
    final buffer = StringBuffer();
    buffer.writeln('/// Helper function to create $className from TOON map');
    buffer.writeln(
      '$className \$${className}FromToon(Map<String, dynamic> toon) {',
    );

    // Find constructor
    // In analyzer 8.x, the default constructor has name == 'new'
    // In analyzer 6.x and earlier, it was '' (empty string)
    final constructor = element.constructors.firstWhere(
      (c) {
        final constructorName = c.name;
        // Default constructor in analyzer 8.x: name is 'new'
        // Default constructor in analyzer <8.x: name is '' or null
        return constructorName == 'new' ||
            constructorName == '' ||
            constructorName == null ||
            constructorName.isEmpty;
      },
      orElse: () {
        final names = element.constructors.map((c) => "'${c.name}'").join(', ');
        throw InvalidGenerationSource(
          'No default constructor found for $className. Available constructors: $names',
          element: element,
        );
      },
    );

    buffer.write('  return $className(');

    final positionalArgs = <String>[];
    final namedArgs = <String>[];

    for (final param in constructor.formalParameters) {
      final fieldName = param.name!;
      final field = element.fields.firstWhere(
        (f) => f.name == fieldName,
        orElse: () => throw InvalidGenerationSource(
          'Field $fieldName not found in $className',
          element: element,
        ),
      );

      final fieldAnnotation = _getFieldAnnotation(field);
      if (fieldAnnotation != null && !fieldAnnotation['include']) {
        continue;
      }

      final toonName = (fieldAnnotation?['name'] as String?) ?? fieldName;
      final deserializedValue = _deserializeField(field, toonName);

      if (param.isNamed) {
        namedArgs.add('$fieldName: $deserializedValue');
      } else {
        positionalArgs.add(deserializedValue);
      }
    }

    if (positionalArgs.isNotEmpty) {
      buffer.write('\n    ${positionalArgs.join(',\n    ')},\n  ');
    }

    if (namedArgs.isNotEmpty) {
      buffer.write('\n    ${namedArgs.join(',\n    ')},\n  ');
    }

    buffer.writeln(');');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Deserialize a field from TOON map
  String _deserializeField(FieldElement field, String toonName) {
    final fieldType = field.type;
    final fieldAnnotation = _getFieldAnnotation(field);

    // Check for custom converter
    if (fieldAnnotation != null && fieldAnnotation['converter'] != null) {
      final converterType = fieldAnnotation['converter'];
      return 'const $converterType().fromToon(toon[\'$toonName\'])';
    }

    // Handle primitives
    if (_isPrimitive(fieldType)) {
      return 'toon[\'$toonName\'] as ${fieldType.getDisplayString()}';
    }

    // Handle collections
    if (_isListType(fieldType)) {
      final elementType = (fieldType as InterfaceType).typeArguments.first;
      if (_isPrimitive(elementType)) {
        final castCode =
            '(toon[\'$toonName\'] as List).cast<${elementType.getDisplayString()}>()';
        if (fieldType.nullabilitySuffix == NullabilitySuffix.question) {
          return 'toon[\'$toonName\'] == null ? null : $castCode';
        }
        return castCode;
      }
      final mapCode =
          '(toon[\'$toonName\'] as List).map((e) => \$${_getDisplayStringWithoutNullability(elementType)}FromToon(e as Map<String, dynamic>)).toList()';
      if (fieldType.nullabilitySuffix == NullabilitySuffix.question) {
        return 'toon[\'$toonName\'] == null ? null : $mapCode';
      }
      return mapCode;
    }

    if (_isMapType(fieldType)) {
      return 'toon[\'$toonName\'] as Map<String, dynamic>';
    }

    // Handle nested objects
    final typeName = _getDisplayStringWithoutNullability(fieldType);
    if (fieldType.nullabilitySuffix == NullabilitySuffix.question) {
      return 'toon[\'$toonName\'] == null ? null : \$${typeName}FromToon(toon[\'$toonName\'] as Map<String, dynamic>)';
    }
    return '\$${typeName}FromToon(toon[\'$toonName\'] as Map<String, dynamic>)';
  }

  /// Get ToonField annotation data for a field
  Map<String, dynamic>? _getFieldAnnotation(FieldElement field) {
    try {
      // Find ToonField annotation using TypeChecker
      final toonFieldChecker = TypeChecker.fromUrl(
        'package:flutter_car_toon/src/annotations/toon_field.dart#ToonField',
      );

      final annotation = toonFieldChecker.firstAnnotationOf(field);
      if (annotation == null) return null;

      final reader = ConstantReader(annotation);

      return {
        'name': reader.read('name').literalValue as String?,
        'include': reader.read('include').literalValue as bool? ?? true,
        'includeIfNull': reader.read('includeIfNull').literalValue as bool?,
        'converter': () {
          final converterField = reader.read('converter');
          if (converterField.isNull) return null;
          final converterType = converterField.typeValue;
          return _getDisplayStringWithoutNullability(converterType);
        }(),
      };
    } catch (e) {
      return null;
    }
  }

  /// Get type name without nullability suffix
  String _getDisplayStringWithoutNullability(DartType type) {
    final displayString = type.getDisplayString();
    return displayString.endsWith('?')
        ? displayString.substring(0, displayString.length - 1)
        : displayString;
  }

  /// Check if type is a primitive
  bool _isPrimitive(DartType type) {
    final typeName = _getDisplayStringWithoutNullability(type);
    return typeName == 'int' ||
        typeName == 'double' ||
        typeName == 'String' ||
        typeName == 'bool' ||
        typeName == 'num';
  }

  /// Check if type is a List
  bool _isListType(DartType type) {
    return type.isDartCoreList;
  }

  /// Check if type is a Map
  bool _isMapType(DartType type) {
    return type.isDartCoreMap;
  }
}
