# TOON CLI Tool Documentation

The TOON CLI provides command-line tools for working with TOON format files, including formatting, validation, conversion, and minification.

## Installation

After installing the `flutter_car_toon` package, activate the CLI globally:

```bash
dart pub global activate flutter_car_toon
```

Or run it directly from your project:

```bash
dart run flutter_car_toon:toon <command>
```

## Commands

### 1. Format

Format and prettify TOON files with consistent indentation and spacing.

**Usage:**

```bash
toon format [options] <file>
```

**Options:**

- `-i, --indent <num>` - Number of spaces for indentation (default: 2)
- `-c, --check` - Check if file is already formatted (exit 0 if formatted, 1 if not)
- `-w, --write` - Write formatted output back to the file
- `-o, --output <file>` - Write output to specified file

**Examples:**

Format and print to stdout:

```bash
toon format example.toon
```

Check if a file is properly formatted:

```bash
toon format --check example.toon
```

Format with 4-space indentation:

```bash
toon format --indent 4 --write example.toon
```

Format to a new file:

```bash
toon format --output formatted.toon example.toon
```

### 2. Validate

Validate TOON syntax and structure to ensure correctness.

**Usage:**

```bash
toon validate [options] <file>
```

**Options:**

- `-s, --strict` - Use strict validation mode (enforces TOON specification strictly)
- `-v, --verbose` - Show detailed error messages with context

**Examples:**

Basic validation:

```bash
toon validate data.toon
```

Strict validation with verbose output:

```bash
toon validate --strict --verbose data.toon
```

**Output:**

- Exit code 0: File is valid
- Exit code 1: Validation errors found
- Displays error severity, message, location, and context

### 3. Convert

Convert between JSON and TOON formats bidirectionally.

**Usage:**

```bash
toon convert --from <format> --to <format> [options] <file>
```

**Required Options:**

- `-f, --from <format>` - Source format: `json` or `toon`
- `-t, --to <format>` - Target format: `json` or `toon`

**Optional:**

- `-o, --output <file>` - Write output to specified file
- `-p, --pretty` - Pretty print output (formatted with indentation)

**Examples:**

Convert JSON to TOON:

```bash
toon convert --from json --to toon data.json
```

Convert TOON to JSON with pretty printing:

```bash
toon convert --from toon --to json --pretty data.toon
```

Convert and save to file:

```bash
toon convert --from json --to toon --output data.toon input.json
```

Round-trip conversion (JSON → TOON → JSON):

```bash
toon convert --from json --to toon --output temp.toon data.json
toon convert --from toon --to json --output result.json temp.toon
```

### 4. Minify

Minify TOON files for compact output and reduced file size.

**Usage:**

```bash
toon minify [options] <file>
```

**Options:**

- `-o, --output <file>` - Write output to specified file

**Examples:**

Minify and print to stdout:

```bash
toon minify data.toon
```

Minify and save to file (shows size comparison):

```bash
toon minify --output data.min.toon data.toon
```

**Output:**
Shows original size, minified size, and percentage savings.

## Global Options

Available for all commands:

- `-h, --help` - Display help information for a command
- `-v, --version` - Display CLI version

**Examples:**

```bash
toon --version
toon --help
toon format --help
```

## Exit Codes

- `0` - Success
- `1` - Error (file not found, validation failed, conversion error, etc.)

## Error Handling

The CLI provides detailed error messages with context:

- **File not found**: Clear message with the missing file path
- **Parsing errors**: Line/column information and source excerpt
- **Validation errors**: Severity level, message, and suggestions
- **Conversion errors**: Detailed information about what went wrong

## Common Workflows

### Format All TOON Files in a Directory

```bash
for file in *.toon; do
  toon format --write "$file"
  echo "Formatted: $file"
done
```

### Validate Before Committing

```bash
#!/bin/bash
# validate-toon.sh
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.toon$'); do
  if ! toon validate --strict "$file"; then
    echo "Validation failed for: $file"
    exit 1
  fi
done
echo "All TOON files validated successfully"
```

### Batch Convert JSON Files to TOON

```bash
for json in *.json; do
  toon convert --from json --to toon --pretty --output "${json%.json}.toon" "$json"
done
```

### CI/CD Integration

```yaml
# .github/workflows/validate-toon.yml
name: Validate TOON Files
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Dart
        uses: dart-lang/setup-dart@v1

      - name: Activate TOON CLI
        run: dart pub global activate flutter_car_toon

      - name: Validate TOON files
        run: |
          find . -name "*.toon" -exec toon validate --strict {} \;

      - name: Check formatting
        run: |
          find . -name "*.toon" -exec toon format --check {} \;
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Validate and format TOON files
toon_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.toon$')

if [ -n "$toon_files" ]; then
  echo "Validating TOON files..."
  for file in $toon_files; do
    # Validate
    if ! toon validate --strict "$file"; then
      echo "❌ Validation failed: $file"
      exit 1
    fi

    # Format
    if ! toon format --check "$file"; then
      echo "Formatting: $file"
      toon format --write "$file"
      git add "$file"
    fi
  done
  echo "✅ All TOON files validated and formatted"
fi
```

## Examples Directory

The package includes example TOON files for testing:

- `examples/simple.toon` - Basic key-value pairs
- `examples/complex.toon` - Nested objects with tabular arrays
- `examples/nested.toon` - Deep nesting examples
- `examples/arrays.toon` - Various array formats
- `examples/simple.json` - JSON file for conversion testing

Try the CLI with these examples:

```bash
# Format example
dart run flutter_car_toon:toon format examples/simple.toon

# Validate complex structure
dart run flutter_car_toon:toon validate examples/complex.toon

# Convert JSON to TOON
dart run flutter_car_toon:toon convert --from json --to toon --pretty examples/simple.json

# Minify
dart run flutter_car_toon:toon minify examples/nested.toon
```

## Performance Tips

1. **Batch operations**: When processing multiple files, consider parallel processing
2. **Validation**: Use `--strict` mode in CI/CD, standard mode for development
3. **Formatting**: Use `--check` in CI to verify without modifying files
4. **Large files**: Minify before distribution to reduce bandwidth

## Troubleshooting

### CLI Not Found

```bash
# Make sure you've activated the package globally
dart pub global activate flutter_car_toon

# Or run directly
dart run flutter_car_toon:toon --version
```

### Permission Denied

```bash
# Make the CLI executable (Unix/macOS)
chmod +x bin/toon.dart
```

### Validation Errors

```bash
# Use verbose mode to see detailed context
toon validate --verbose --strict problematic.toon
```

## Contributing

Found a bug or want to suggest a feature? Please visit our [GitHub repository](https://github.com/BullsEye34/flutter_car_toon/issues).

## License

MIT License - See LICENSE file for details.
