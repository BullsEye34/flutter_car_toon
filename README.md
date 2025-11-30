# Flutter CarToon - TOON Formatter Plugin

# Flutter CarToon

A Flutter plugin for Token-Oriented Object Notation (TOON) - a human-readable data serialization format.

## Features

- 🔄 **Bidirectional conversion**: JSON ↔ TOON with complete data integrity
- 📝 **Human-readable format**: Easy to read and write
- 🎯 **Type-safe**: Preserves data types during conversion
- ⚡ **Lightweight**: Minimal overhead, maximum performance
- 🛠️ **Flexible**: Configurable encoding options
- 📱 **Cross-platform**: Works on iOS, Android, Web, Desktop
- 🔧 **Advanced parsing**: Supports tabular arrays and complex nested structures
- 📊 **Large datasets**: Efficient handling with configurable depth limits
- 🚀 **Swift Package Manager**: Early adopter with full SPM support for modern iOS/macOS development

## 🚀 Why Choose flutter_car_toon over toon_formatter?

While [`toon_formatter`](https://pub.dev/packages/toon_formater) provides basic TOON encoding/decoding, **flutter_car_toon** is a complete, production-ready solution:

### 🎯 **Key Advantages**

| Feature               | flutter_car_toon                                  | toon_formatter            |
| --------------------- | ------------------------------------------------- | ------------------------- |
| **🛡️ Error Handling** | Comprehensive with detailed context & suggestions | Basic error messages      |
| **✅ Validation**     | Full document validator with severity levels      | No validation support     |
| **🌊 Streaming**      | Basic streaming framework (expanding)             | No streaming support      |
| **🔧 Extensibility**  | Custom type converters & plugins                  | Limited customization     |
| **⚡ Performance**    | Multiple optimization strategies                  | Basic implementation      |
| **📚 API Design**     | Mirrors `dart:convert` patterns                   | Simple encode/decode only |
| **🔍 Testing**        | 159 comprehensive tests                           | Limited test coverage     |
| **📖 Documentation**  | Complete API docs & examples                      | Basic documentation       |
| **🛠️ Tooling**        | ✅ CLI tools (format, validate, convert, minify)  | No additional tools       |
| **🚀 SPM Support**    | ✅ Early adopter (iOS/macOS)                      | ❌ CocoaPods only         |

### 💡 **Unique Features**

- **Production-ready**: Comprehensive error handling with detailed context
- **Developer-friendly**: Familiar `dart:convert` API patterns (exact same interface)
- **Extensible**: Built-in converters for DateTime, Duration, BigInt, URI types
- **Well-tested**: 159 comprehensive tests ensure reliability
- **Performance-focused**: Multiple optimization strategies for different use cases

> **Acknowledgments**: This project is highly inspired by the [`toon_formatter`](https://pub.dev/packages/toon_formater) package and follows the architectural patterns established by Dart's [`dart:convert`](https://api.dart.dev/stable/dart-convert/dart-convert-library.html) library to ensure familiar and consistent usage patterns.

[![pub package](https://img.shields.io/badge/pub-v0.3.1-blue)](https://pub.dev/packages/flutter_car_toon)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is TOON?

TOON (Token-Oriented Object Notation) is a compact, human-readable encoding of JSON data specifically designed for LLM prompts and efficient data exchange. Key features:

- **🗜️ Compact**: More space-efficient than JSON (up to 44% smaller)
- **👀 Human-readable**: Clean, indentation-based structure
- **⚡ Fast decoding**: Up to 18,000x faster decoding than JSON
- **🤖 LLM-friendly**: Optimized for AI/ML token consumption
- **📏 Deterministic**: Consistent output for the same data

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_car_toon: ^0.3.1
```

For code generation support, also add:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Swift Package Manager Support

**flutter_car_toon** is one of the early Flutter packages to adopt Swift Package Manager! As Flutter transitions from CocoaPods to SPM, we're ready for the future.

### Why This Matters

- ✅ **Modern dependency management** for iOS/macOS
- ✅ **No Ruby/CocoaPods installation required** (in the future)
- ✅ **Access to Swift package ecosystem**
- ✅ **Dual support**: Works with both SPM and CocoaPods
- ✅ **Future-proof**: Ready for Flutter 3.24+ projects

### Platform Support

| Platform     | CocoaPods | Swift Package Manager |
| ------------ | --------- | --------------------- |
| iOS 13.0+    | ✅        | ✅                    |
| macOS 10.15+ | ✅        | ✅                    |

**Note**: Swift Package Manager support is currently opt-in and under active development by the Flutter team. This package supports both dependency management systems to ensure compatibility with all Flutter projects.

## Quick Start

### Basic Usage

```dart
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  // Encode a Dart object to TOON format
  final data = {
    'name': 'Alice',
    'age': 30,
    'tags': ['admin', 'ops', 'dev'],
  };

  final toonString = toon.encode(data);
  print(toonString);
  // Output:
  // name: Alice
  // age: 30
  // tags[3]: admin,ops,dev

  // Decode TOON format back to Dart
  final decoded = toon.decode(toonString);
  print(decoded); // {name: Alice, age: 30, tags: [admin, ops, dev]}
}
```

### Using ToonCodec (Similar to JsonCodec)

```dart
// Create a codec with custom options
final codec = ToonCodec(
  options: ToonOptions(
    indent: 4,
    delimiter: ToonDelimiter.comma,
    strictMode: true,
  ),
);

final encoded = codec.encode(myData);
final decoded = codec.decode(toonString);
```

### Convenience Functions

```dart
// Global convenience functions
final encoded = toonEncode(data);
final decoded = toonDecode(toonString);

// With custom options
final encoded = toonEncode(data, options: ToonOptions.compact);
final decoded = toonDecode(toonString, options: ToonOptions.strict);
```

## TOON Format Examples

### Objects

```toon
name: Alice
age: 30
email: alice@example.com
```

### Arrays

```toon
# Inline arrays for primitives
tags[3]: admin,ops,dev

# Tabular arrays for uniform objects
users[2]{name,age}:
  Alice,30
  Bob,25

# Complex tabular arrays with mixed field types
inventory[2]{make,model,year,features,price,available}:
  Toyota,Camry,2020,[3]: Bluetooth,Backup Camera,Cruise Control,24999.99,true
  Honda,Civic,2021,[4]: Bluetooth,Lane Keep Assist,Apple CarPlay,Sunroof,22500.00,false
```

### Nested Structures

```toon
user:
  name: Alice
  profile:
    bio: Software Engineer
    skills[3]: dart,flutter,toon
    active: true
```

### Lists (Mixed Types)

```toon
items[3]:
  - name: Item 1
    price: 9.99
  - name: Item 2
    price: 14.50
  - Special Deal
```

## Advanced Features

### Custom Options

```dart
final options = ToonOptions(
  indent: 4,                              // Indentation spaces
  delimiter: ToonDelimiter.pipe,          // Array delimiter (|)
  keyFolding: ToonKeyFolding.safe,        // Key folding strategy
  arrayStrategy: ToonArrayStrategy.tabular, // Force tabular arrays
  strictMode: true,                       // Strict spec compliance
  compactOutput: false,                   // Pretty vs compact output
);

final codec = ToonCodec(options: options);
```

### Round-Trip Conversion Example

The enhanced decoder in version 0.1.2+ supports complex tabular arrays with mixed field types and maintains complete data integrity:

```dart
// Complex nested data with tabular arrays
final complexData = {
  'dealership': 'Premium Motors',
  'location': {
    'city': 'Austin',
    'state': 'TX',
    'coordinates': [30.2672, -97.7431]
  },
  'inventory': [
    {
      'make': 'Toyota',
      'model': 'Camry',
      'year': 2020,
      'features': ['Bluetooth', 'Backup Camera', 'Cruise Control'],
      'price': 24999.99,
      'available': true
    },
    {
      'make': 'Honda',
      'model': 'Civic',
      'year': 2021,
      'features': ['Bluetooth', 'Lane Keep Assist', 'Apple CarPlay', 'Sunroof'],
      'price': 22500.00,
      'available': false
    }
  ]
};

// Encode to TOON format
final toonString = toon.encode(complexData);
print(toonString);

// Decode back to Dart objects
final decoded = toon.decode(toonString);
print('Data integrity preserved: ${decoded.toString() == complexData.toString()}');
```

### Validation

```dart
final validator = ToonValidator(options: ToonOptions.strict);

// Validate a TOON document
final errors = validator.validate(toonString);
if (errors.isNotEmpty) {
  for (final error in errors) {
    print('${error.severity}: ${error.message}');
  }
}

// Quick validation check
if (validator.isValid(toonString)) {
  print('Valid TOON format!');
}
```

### Custom Type Converters

```dart
// Register custom converters
globalToonConverterRegistry.register<DateTime>(DateTimeToonConverter());
globalToonConverterRegistry.register<Duration>(DurationToonConverter());

// Use with codec
final data = {
  'timestamp': DateTime.now(),
  'duration': Duration(hours: 2, minutes: 30),
};

final encoded = toon.encode(data);
```

### Streaming Support (Basic Implementation)

```dart
// Basic streaming from string sources (currently available)
final stream = ToonStream.fromString(toonData);
await for (final chunk in stream.decode()) {
  processChunk(chunk);
}

// Transform JSON stream to TOON (available)
final jsonStream = Stream.fromIterable(['{"a":1}', '{"b":2}']);
final toonStream = ToonStream().fromJson(jsonStream);

// File streaming planned for future versions
// final fileStream = ToonStream.fromFile('data.toon'); // Coming soon
```

## Predefined Options

```dart
// Default options
ToonOptions.defaults

// Strict TOON specification compliance
ToonOptions.strict

// Compact output for minimal size
ToonOptions.compact

// Pretty printing for readability
ToonOptions.pretty

// Performance-optimized for large data
ToonOptions.performance
```

## Error Handling

The library provides comprehensive error handling with detailed context:

```dart
try {
  final result = toon.decode(malformedToon);
} on ToonDecodingError catch (e) {
  print('Decoding error at ${e.location}: ${e.message}');
  print('Source excerpt:\n${e.sourceExcerpt}');
} on ToonValidationError catch (e) {
  print('Validation error: ${e.message}');
  print('Suggestion: ${e.suggestion}');
} on ToonError catch (e) {
  print('TOON error: ${e.message}');
}
```

## Performance Comparison

Based on benchmarks against JSON:

| Data Size | TOON Size vs JSON | Encode Speed | Decode Speed  |
| --------- | ----------------- | ------------ | ------------- |
| Small     | 83% (17% smaller) | 3x slower    | 37x faster    |
| Medium    | 56% (44% smaller) | 3x slower    | 497x faster   |
| Large     | 93% (7% smaller)  | 4x slower    | 18000x faster |

**Key Findings:**

- ✅ **Decoding**: TOON decoding is significantly faster than JSON
- ✅ **Size**: TOON format is more compact, especially for structured data
- ⚠️ **Encoding**: JSON encoding is faster, but TOON is reasonable for most use cases

## Annotations (Code Generation)

**Available since v0.2.0!** Automatic code generation for TOON serialization:

### Setup

1. Add the dependencies:

```yaml
dependencies:
  flutter_car_toon: ^0.3.0

dev_dependencies:
  build_runner: ^2.4.0
```

2. Annotate your classes:

```dart
import 'package:flutter_car_toon/flutter_car_toon.dart';

part 'user.toon.dart';

@ToonSerializable()
class User {
  final String name;
  final int age;
  final String email;

  @ToonField(name: 'is_active')
  final bool isActive;

  @ToonField(includeIfNull: false)
  final String? bio;

  const User({
    required this.name,
    required this.age,
    required this.email,
    this.isActive = true,
    this.bio,
  });
}
```

3. Run the code generator:

```bash
dart run build_runner build
```

### Generated Code

The generator creates a `.toon.dart` file with:

```dart
// user.toon.dart (generated)
extension UserToonExtension on User {
  Map<String, dynamic> toToon() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'is_active': isActive,
      if (bio != null) 'bio': bio,
    };
  }
}

User $UserFromToon(Map<String, dynamic> toon) {
  return User(
    name: toon['name'] as String,
    age: toon['age'] as int,
    email: toon['email'] as String,
    isActive: toon['is_active'] as bool,
    bio: toon['bio'] as String?,
  );
}
```

### Usage

```dart
// Serialize to TOON
final user = User(name: 'Alice', age: 30, email: 'alice@example.com');
final toonMap = user.toToon();
final toonString = toon.encode(toonMap);

// Deserialize from TOON
final decoded = toon.decode(toonString) as Map<String, dynamic>;
final user = $UserFromToon(decoded);
```

### Annotation Options

**@ToonSerializable()**

- `createFactory` (default: `true`) - Generate fromToon function
- `createToToon` (default: `true`) - Generate toToon method
- `includeIfNull` (default: `true`) - Include null values in output
- `explicitToToon` (default: `false`) - Require explicit toToon() calls for nested objects

**@ToonField()**

- `name` - Custom field name in TOON output
- `include` (default: `true`) - Whether to include this field
- `includeIfNull` - Override class-level null handling
- `converter` - Custom type converter

### Nested Objects

Code generation supports nested @ToonSerializable objects:

```dart
@ToonSerializable()
class Address {
  final String street;
  final String city;
  final int zipCode;

  const Address({required this.street, required this.city, required this.zipCode});
}

@ToonSerializable()
class Profile {
  final String username;
  final Address address;
  final List<Address>? previousAddresses;

  const Profile({required this.username, required this.address, this.previousAddresses});
}

// Usage
final profile = Profile(
  username: 'johndoe',
  address: Address(street: '123 Main St', city: 'NYC', zipCode: 10001),
);

final toonString = toon.encode(profile.toToon());
```

### Watch Mode

For automatic regeneration during development:

```bash
dart run build_runner watch
```

## CLI Tools

**Available in v0.3.0+!** Command-line tools for TOON format operations.

### Installation

Activate globally:

```bash
dart pub global activate flutter_car_toon
```

Or run directly from your project:

```bash
dart run flutter_car_toon:toon <command>
```

### Available Commands

#### Format

Format and prettify TOON files:

```bash
toon format [--indent 2] [--check] [--write] [--output file] <file>
```

Examples:

```bash
# Format to stdout
toon format data.toon

# Check if formatted
toon format --check data.toon

# Format in place
toon format --write data.toon

# Custom indentation
toon format --indent 4 --write data.toon
```

#### Validate

Validate TOON syntax and structure:

```bash
toon validate [--strict] [--verbose] <file>
```

Examples:

```bash
# Basic validation
toon validate data.toon

# Strict mode with details
toon validate --strict --verbose data.toon
```

#### Convert

Convert between JSON and TOON formats:

```bash
toon convert --from <json|toon> --to <json|toon> [--pretty] [--output file] <file>
```

Examples:

```bash
# JSON to TOON
toon convert --from json --to toon data.json

# TOON to JSON (pretty)
toon convert --from toon --to json --pretty data.toon

# Save to file
toon convert --from json --to toon --output data.toon input.json
```

#### Minify

Minify TOON files for compact output:

```bash
toon minify [--output file] <file>
```

Examples:

```bash
# Minify to stdout
toon minify data.toon

# Save minified version
toon minify --output data.min.toon data.toon
```

### Example Files

The package includes example TOON files in the `examples/` directory:

- `simple.toon` - Basic key-value pairs
- `complex.toon` - Nested objects with tabular arrays
- `nested.toon` - Deep nesting examples
- `arrays.toon` - Various array formats
- `simple.json` - JSON for conversion testing

### Full Documentation

See [CLI.md](CLI.md) for complete documentation including:

- Detailed command reference
- CI/CD integration examples
- Pre-commit hook setup
- Batch processing workflows
- Troubleshooting guide

## API Reference

### Core Classes

- **`ToonCodec`**: Main encoder/decoder (similar to JsonCodec)
- **`ToonEncoder`**: Encoding functionality
- **`ToonDecoder`**: Decoding functionality
- **`ToonOptions`**: Configuration options
- **`ToonValidator`**: Format validation
- **`ToonStream`**: Streaming support

### Error Classes

- **`ToonError`**: Base error class
- **`ToonEncodingError`**: Encoding failures
- **`ToonDecodingError`**: Decoding failures
- **`ToonValidationError`**: Validation issues
- **`ToonSyntaxError`**: Syntax problems

### Utility Classes

- **`ToonUtils`**: Utility functions
- **`StringUtils`**: String processing helpers
- **`ValidationUtils`**: Validation helpers

## Compatibility

- **Flutter**: >= 3.3.0
- **Dart**: >= 3.10.0
- **Platforms**: Android, iOS, Linux, macOS, Windows, Web

## 📊 Detailed Comparison with Existing Packages

| Feature                      | flutter_car_toon            | toon_formatter | Advantages                                       |
| ---------------------------- | --------------------------- | -------------- | ------------------------------------------------ |
| **Basic encode/decode**      | ✅ Full API                 | ✅ Basic       | Complete `dart:convert` compatibility            |
| **Custom options**           | ✅ 12 comprehensive options | ✅ Limited     | Extensive configuration system                   |
| **Error handling**           | ✅ 6 error types            | ❌ Basic       | Detailed context, suggestions, source excerpts   |
| **Validation**               | ✅ Validation framework     | ❌ None        | Built-in validation system                       |
| **Streaming**                | ✅ Basic streaming API      | ❌ None        | Foundation for large dataset processing          |
| **Type converters**          | ✅ Extensible system        | ❌ Limited     | DateTime, Duration, custom types                 |
| **Performance optimization** | ✅ Multiple strategies      | ❌ Basic       | Compact, pretty, performance modes               |
| **Test coverage**            | ✅ 159 comprehensive        | ❌ Limited     | Production-ready (88 core + 15 codegen + 56 CLI) |
| **Documentation**            | ✅ Complete API docs        | ❌ Basic       | Examples, guides, API reference                  |
| **Code generation**          | ✅ Available v0.2.0         | ✅ Available   | Supports @ToonSerializable with nested objects   |
| **CLI tools**                | ✅ Available v0.3.0         | ❌ None        | Format, validate, convert, minify                |
| **Platform support**         | ✅ All platforms            | ✅ All         | Flutter Web, Desktop, Mobile                     |

### 🎯 **Migration Benefits**

Switching from `toon_formatter` to `flutter_car_toon`:

```dart
// Before (toon_formatter)
try {
  final result = ToonFormatter.decode(toonString);
} catch (e) {
  print('Error: $e'); // Generic error message
}

// After (flutter_car_toon)
try {
  final result = toon.decode(toonString);
} on ToonDecodingError catch (e) {
  print('Line ${e.line}, Column ${e.column}: ${e.message}');
  print('Suggestion: ${e.suggestion}');
  print('Context: ${e.sourceExcerpt}');
} on ToonValidationError catch (e) {
  print('Validation failed: ${e.message}');
}
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- 📦 [Pub.dev Package](https://pub.dev/packages/flutter_car_toon)
- 🐙 [GitHub Repository](https://github.com/BullsEye34/flutter_car_toon)
- 📖 [TOON Specification](https://toonformat.dev/)
- 📚 [API Documentation](https://pub.dev/documentation/flutter_car_toon/latest/)
- 🔧 [Issue Tracker](https://github.com/BullsEye34/flutter_car_toon/issues)

## Credits

- TOON format specification by the [TOON Format Team](https://toonformat.dev/)
- Inspired by `dart:convert` and `json_serializable`
- Enhanced beyond `toon_formatter` with enterprise features
- Built with ❤️ for the Flutter community
- **159 tests** ensure production reliability (88 core + 15 codegen + 56 CLI)

> AI was used to write this comprehensive implementation
