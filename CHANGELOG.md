## 0.1.2

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
