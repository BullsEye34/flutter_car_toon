# Changelog

## [0.3.1] - 2024-12-01

### Fixed

- Fixed pub.dev static analysis by disabling `avoid_print` lint rule
  - Print statements are necessary and correct for CLI tools
  - Ensures 50/50 score on pub.dev static analysis

### Changed

- Updated `analysis_options.yaml` to allow print statements in CLI context
- Removed bin/ directory exclusion (not respected by pub.dev analyzer)

## [0.3.0] - 2024-11-30

### Added

- 🚀 **CLI Tools** - Comprehensive command-line interface for TOON format operations
  - `format` - Format and prettify TOON files with customizable indentation
  - `validate` - Validate TOON syntax with strict mode and verbose error reporting
  - `convert` - Bidirectional conversion between JSON and TOON formats
  - `minify` - Minify TOON files for compact output with size comparison
  - Global `--help` and `--version` flags
  - Detailed error messages with context and suggestions
  - Support for stdin/stdout and file I/O operations
  - Example TOON files for testing CLI functionality
- **CLI Documentation** - Complete CLI.md guide with:
  - Installation instructions
  - Command reference with all options
  - Common workflows (batch operations, CI/CD integration, pre-commit hooks)
  - Examples directory with sample files
  - Troubleshooting guide
- **CLI Tests** - 15 comprehensive test suites (103 total tests):
  - Version and help command tests
  - Format command with check, write, and output options
  - Validate command with strict and verbose modes
  - Convert command for JSON ↔ TOON conversion
  - Minify command with size reporting
  - Error handling and edge cases
  - Integration tests for multi-command pipelines

### Changed

- Updated README with CLI tools marked as ✅ available in comparison table
- Added `args: ^2.6.0` dependency for command-line argument parsing
- Added `executables` section to pubspec.yaml for global CLI activation
- Updated documentation to reflect completed v0.3.0 milestone

### Dependencies

- Added `args: ^2.6.0` for CLI argument parsing

## [0.2.2] - 2024-11-30

### Fixed

- Fixed Dart formatting issues for pub.dev validation
- Added missing generated .toon.dart files to repository

## [0.2.1] - 2024-11-30

### Updated

- Updated dependencies to latest compatible versions:
  - analyzer: ^9.0.0 (latest)
  - build: ^4.0.3 (latest)
  - source_gen: ^4.1.1 (latest)
- Removed unused dev dependencies (test, json_serializable, json_annotation)
- Fixed analyzer 9.x API compatibility

## [0.2.0] - 2024-11-30

### Added

- 🎉 **Code Generation System** - Automatic TOON serialization with build_runner
  - `@ToonSerializable()` annotation for classes
  - `@ToonField()` annotation for field-level customization
  - Generates `.toon.dart` files with `toToon()` extension methods and `$ClassFromToon()` factory functions
  - Support for nested @ToonSerializable objects with automatic recursive serialization
  - List support for both primitives and nested objects
  - Nullable type handling with proper null checks
  - Custom field naming (`@ToonField(name: 'custom_name')`)
  - Conditional field inclusion (`@ToonField(includeIfNull: false)`)
  - Full integration with existing TOON encoder/decoder

### Features

- **Generator Configuration** - Comprehensive annotation options:
  - `createFactory` - Control factory function generation
  - `createToToon` - Control toToon method generation
  - `includeIfNull` - Global null handling strategy
  - `explicitToToon` - Explicit nested object serialization
- **Type Support** - Handles all Dart primitives, collections, and custom types
- **Build Integration** - Seamless build_runner integration with proper `build.yaml` configuration
- **Part Files** - Standard Dart part file pattern for generated code

### Testing

- Added 15 comprehensive tests for code generation (103 total tests)
- Tests cover simple objects, nested objects, lists, nullables, and round-trip serialization
- Separate test suites for basic and nested object scenarios
- Full TOON format integration testing

### Documentation

- Updated README with complete code generation guide
- Added setup instructions and usage examples
- Documented all annotation parameters and options
- Included nested object serialization examples
- Added watch mode and development workflow guidance

### Project Structure

- Organized example models in `lib/examples/` directory
- Created proper test structure for generated code validation
- Added example models: User, Person, Address, Profile

### Dependencies

- Added `source_gen: ^1.5.0` for code generation
- Added `build: ^2.4.1` for build system integration
- Added `analyzer: ^6.4.1` for Dart code analysis
- Updated example with `build_runner: ^2.4.10`

## [0.1.6] - 2024-11-29

### Changed

- 📚 **Documentation Enhancement** - Prominently highlighted Swift Package Manager early adoption
  - Added dedicated SPM section in README showcasing benefits and platform support
  - Featured SPM support in comparison table as key differentiator
  - Emphasized dual CocoaPods/SPM compatibility for maximum flexibility
  - Positioned package as future-ready for Flutter 3.24+ projects

### Marketing

- Showcased early adopter status of Flutter's modern iOS/macOS dependency management
- Enhanced package visibility for developers seeking future-proof solutions

## [0.1.5] - 2024-11-29

### Added

- ✨ **Swift Package Manager Support** - Full implementation for modern iOS/macOS dependency management
  - Created Package.swift files for both iOS and macOS platforms
  - Proper directory structure: `ios/flutter_car_toon/` and `macos/flutter_car_toon/`
  - Migrated Swift source files to SPM-compatible locations
  - Privacy manifests configured and integrated
  - Dual support: Works with both CocoaPods and Swift Package Manager

### Changed

- Updated podspec files with proper metadata (license type, description, git source)
- Synchronized podspec versions with pub package version
- Updated macOS minimum deployment target to 10.15 (matching Package.swift requirements)

### Fixed

- Resolved all CocoaPods validation warnings
- Fixed podspec source paths to point to new Swift Package Manager structure

## [0.1.4] - 2024-11-24

### Fixed

- Fixed Dart formatting issues across multiple files
- Resolved formatting problems in flutter_car_toon_method_channel.dart and big_int_converter.dart
- Achieved full compliance with Dart formatter for perfect pub.dev static analysis score

### Changed

- Applied consistent Dart formatting across entire codebase
- Enhanced code presentation and readability

## [0.1.3] - 2024-11-24

### Fixed

- Fixed curly_braces_in_flow_control_structures linting violations in ToonDecoder
- Added proper braces to single-line while statements for improved code quality
- Achieved zero linting errors to improve pub.dev static analysis score

### Changed

- Enhanced code style compliance while maintaining all functionality
- Updated documentation to reflect latest version

## [0.1.2] - 2024-11-19

- **CRITICAL BUG FIX** - Fixed `toon.decode()` tabular array format not working properly
- **Enhanced ToonDecoder** - Complete rewrite with comprehensive parsing capabilities:
  - Tabular arrays: `inventory[2]{make,model,year}:` format support
  - Inline arrays within tabular data: `[3]: value1,value2,value3` parsing
  - Proper 4-space indentation detection for nested structures
  - Enhanced type detection for all primitives, numbers, booleans, arrays
- **Round-trip Integrity** - JSON→TOON→JSON conversion now preserves complete data integrity
- **Large Dataset Support** - Efficient handling with configurable depth limits (tested with 100+ nested items)
- **Robust Parsing** - Improved handling of mixed data types in complex nested structures

## 0.1.1

- **Documentation Enhancement** - Major README improvements with detailed comparison tables
- **Repository Links Fixed** - Updated all GitHub URLs to use correct username (BullsEye34)
- **Code Quality** - Fixed analyzer warnings and improved code cleanliness
- **Test Suite Expansion** - Enhanced test coverage to 88 comprehensive tests
- **Honest Feature Claims** - Clarified actual vs planned features for transparency
- **Version Planning** - Corrected semantic versioning for future releases (0.2.0, 0.3.0)

## 0.1.0

- **Initial release** of Flutter CarToon - comprehensive TOON formatter plugin
- Complete ToonCodec implementation following dart:convert patterns
- Full TOON encoding with support for objects, arrays, and primitives
- Basic TOON decoding for simple data structures
- Comprehensive error handling with detailed context
- Extensible type conversion system with built-in converters
- Flexible configuration system with predefined option sets
- Complete test suite with 22 passing tests
- Interactive example application demonstrating TOON ↔ JSON conversion
- Comprehensive documentation with API reference and usage examples
- Ready for production use with clear roadmap for future enhancements
