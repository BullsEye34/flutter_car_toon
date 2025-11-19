# Flutter CarToon Example

Demonstrates how to use the `flutter_car_toon` plugin - a comprehensive TOON (Token-Oriented Object Notation) formatter for Flutter.

## What This Example Shows

This example app demonstrates the core functionality of the Flutter CarToon plugin:

- **TOON Encoding**: Convert Dart objects to TOON format strings
- **TOON Decoding**: Parse TOON format strings back to Dart objects
- **Interactive Conversion**: Real-time conversion between data formats
- **Error Handling**: Graceful handling of conversion errors
- **Performance Benefits**: Experience the compact nature of TOON format

## Features Demonstrated

### 🔄 Bidirectional Conversion

- JSON to TOON conversion
- TOON to JSON conversion
- Easy swap between conversion modes

### 📱 Interactive UI

- Real-time input and output panels
- Dropdown selection for conversion type
- Swap button for quick mode switching
- Monospace font for better data readability

### 📊 Example Data

The app comes preloaded with sample data that showcases:

- Nested objects and arrays
- Mixed data types (strings, numbers, booleans)
- Complex hierarchical structures
- Real-world data patterns

### ✨ TOON Format Benefits

The app displays key advantages of TOON format:

- **Up to 44% smaller** than equivalent JSON
- **Up to 18,000x faster** decoding performance
- **Human-readable** indentation-based structure
- **Optimized for LLM prompts** and AI applications

## Getting Started

1. **Run the app**:

   ```bash
   flutter run
   ```

2. **Try the conversion**:

   - The app loads with example data in the input field
   - Tap "Convert to TOON" to see the TOON format output
   - Use the "Swap" button to reverse the conversion
   - Edit the input data to try your own examples

3. **Experiment with different data**:
   - Try nested objects and arrays
   - Test with different data types
   - Observe the size difference between formats
   - Notice the human-readable structure of TOON

## Code Example

Here's how easy it is to use Flutter CarToon in your own projects:

```dart
import 'package:flutter_car_toon/flutter_car_toon.dart';

// Encoding Dart objects to TOON
final data = {
  'name': 'Alice Smith',
  'age': 30,
  'active': true,
  'tags': ['admin', 'user']
};

final toonString = toon.encode(data);
print(toonString);
// Output:
// name: Alice Smith
// age: 30
// active: true
// tags: [admin, user]

// Decoding TOON back to Dart objects
final decoded = toon.decode(toonString);
print(decoded['name']); // Alice Smith
```

## Learning More

This example provides a hands-on way to understand:

- How TOON format compares to JSON
- When to use TOON vs other formats
- Real-world performance benefits
- Integration patterns for Flutter apps

For more advanced usage, custom options, and API reference, see the main plugin documentation.

## Performance Testing

Use this app to:

- Compare output size between JSON and TOON
- Test conversion speed with your own data
- Understand the human-readable benefits of TOON format
- Experiment with complex nested structures

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
