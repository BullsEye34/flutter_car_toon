# Flutter CarToon - TOON Formatter Plugin

# Flutter CarToon

A comprehensive **TOON (Token-Oriented Object Notation)** formatter plugin for Flutter that provides all the functionality of `dart:convert`'s JSON library but optimized for the TOON format.

> **Acknowledgments**: This project is highly inspired by the [`toon_formatter`](https://pub.dev/packages/toon_formater) package and follows the architectural patterns established by Dart's [`dart:convert`](https://api.dart.dev/stable/dart-convert/dart-convert-library.html) library to ensure familiar and consistent usage patterns.

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue)](https://pub.dev/packages/flutter_car_toon)
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
  flutter_car_toon: ^1.0.0
```

Then run:

```bash
flutter pub get
```

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

### Streaming Support (Large Data)

```dart
// Stream processing for large datasets
final stream = ToonStream.fromFile('large_data.toon');
await for (final chunk in stream.decode()) {
  processChunk(chunk);
}

// Transform JSON stream to TOON
final jsonStream = Stream.fromIterable(['{"a":1}', '{"b":2}']);
final toonStream = ToonStream().fromJson(jsonStream);
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

Future support for code generation (similar to json_serializable):

```dart
import 'package:flutter_car_toon/flutter_car_toon.dart';

@ToonSerializable()
class User {
  final String name;
  final int age;

  @ToonField(name: 'email_address')
  final String email;

  @ToonField(include: false)
  final String password; // Won't be serialized

  User({required this.name, required this.age, required this.email, required this.password});

  // Generated methods (future):
  // String toToon() => _$UserToToon(this);
  // factory User.fromToon(String toon) => _$UserFromToon(toon);
}
```

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

## Comparison with Existing Packages

| Feature                  | flutter_car_toon       | toon_formater |
| ------------------------ | ---------------------- | ------------- |
| Basic encode/decode      | ✅                     | ✅            |
| Custom options           | ✅                     | ✅            |
| Error handling           | ✅ Comprehensive       | ❌ Basic      |
| Validation               | ✅ Full validator      | ❌ None       |
| Streaming                | ✅ Built-in            | ❌ None       |
| Type converters          | ✅ Extensible          | ❌ Limited    |
| Performance optimization | ✅ Multiple strategies | ❌ Basic      |
| Code generation          | 🚧 Planned             | ✅            |
| CLI tools                | 🚧 Planned             | ❌ None       |

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- 📦 [Pub.dev Package](https://pub.dev/packages/flutter_car_toon)
- 🐙 [GitHub Repository](https://github.com/your_username/flutter_car_toon)
- 📖 [TOON Specification](https://toonformat.dev/)
- 📚 [API Documentation](https://pub.dev/documentation/flutter_car_toon/latest/)
- 🔧 [Issue Tracker](https://github.com/your_username/flutter_car_toon/issues)

## Credits

- TOON format specification by the [TOON Format Team](https://toonformat.dev/)
- Inspired by `dart:convert` and `json_serializable`
- Built with ❤️ for the Flutter community
