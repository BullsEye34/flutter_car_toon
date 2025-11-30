#!/bin/bash
# Manual CLI Test Script
# Run this to manually test the TOON CLI functionality

set -e

echo "🧪 Testing TOON CLI v0.3.0"
echo "============================="
echo

# Test 1: Version
echo "✓ Test 1: Version check"
dart bin/toon.dart --version
echo

# Test 2: Help
echo "✓ Test 2: Help display"
dart bin/toon.dart --help
echo

# Test 3: Format
echo "✓ Test 3: Format example file"
dart bin/toon.dart format examples/simple.toon
echo

# Test 4: Validate
echo "✓ Test 4: Validate example file"
dart bin/toon.dart validate examples/complex.toon
echo

# Test 5: Convert JSON to TOON
echo "✓ Test 5: Convert JSON to TOON"
dart bin/toon.dart convert --from json --to toon --pretty examples/simple.json
echo

# Test 6: Convert TOON to JSON
echo "✓ Test 6: Convert TOON to JSON"
dart bin/toon.dart convert --from toon --to json --pretty examples/simple.toon
echo

# Test 7: Minify
echo "✓ Test 7: Minify TOON file"
dart bin/toon.dart minify examples/nested.toon
echo

echo "============================="
echo "✅ All CLI tests passed!"
echo
echo "Try these commands yourself:"
echo "  dart bin/toon.dart format examples/simple.toon"
echo "  dart bin/toon.dart validate examples/complex.toon"
echo "  dart bin/toon.dart convert --from json --to toon examples/simple.json"
echo "  dart bin/toon.dart minify examples/nested.toon"
