#!/usr/bin/env dart

/// TOON CLI - Command line tools for TOON format
library;

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';
import 'dart:convert';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('format', buildFormatCommand())
    ..addCommand('validate', buildValidateCommand())
    ..addCommand('convert', buildConvertCommand())
    ..addCommand('minify', buildMinifyCommand())
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Print version information',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print this usage information',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['version']) {
      print('TOON CLI v0.3.0');
      print('Part of flutter_car_toon package');
      exit(0);
    }

    if (results['help'] || results.command == null) {
      printUsage(parser);
      exit(0);
    }

    final command = results.command!;
    switch (command.name) {
      case 'format':
        await handleFormat(command);
        break;
      case 'validate':
        await handleValidate(command);
        break;
      case 'convert':
        await handleConvert(command);
        break;
      case 'minify':
        await handleMinify(command);
        break;
      default:
        print('Unknown command: ${command.name}');
        printUsage(parser);
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

ArgParser buildFormatCommand() {
  return ArgParser()
    ..addOption(
      'indent',
      abbr: 'i',
      defaultsTo: '2',
      help: 'Indentation spaces',
    )
    ..addFlag(
      'check',
      abbr: 'c',
      help: 'Check if files are formatted',
      negatable: false,
    )
    ..addFlag(
      'write',
      abbr: 'w',
      help: 'Write formatted output to file',
      negatable: false,
    )
    ..addOption('output', abbr: 'o', help: 'Output file (default: stdout)');
}

ArgParser buildValidateCommand() {
  return ArgParser()
    ..addFlag(
      'strict',
      abbr: 's',
      help: 'Use strict validation mode',
      negatable: false,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Verbose error messages',
      negatable: false,
    );
}

ArgParser buildConvertCommand() {
  return ArgParser()
    ..addOption(
      'from',
      abbr: 'f',
      allowed: ['json', 'toon'],
      mandatory: true,
      help: 'Source format',
    )
    ..addOption(
      'to',
      abbr: 't',
      allowed: ['json', 'toon'],
      mandatory: true,
      help: 'Target format',
    )
    ..addOption('output', abbr: 'o', help: 'Output file (default: stdout)')
    ..addFlag(
      'pretty',
      abbr: 'p',
      help: 'Pretty print output',
      negatable: false,
    );
}

ArgParser buildMinifyCommand() {
  return ArgParser()
    ..addOption('output', abbr: 'o', help: 'Output file (default: stdout)');
}

void printUsage(ArgParser parser) {
  print('TOON CLI - Command line tools for TOON format\n');
  print('Usage: toon <command> [arguments]\n');
  print('Available commands:');
  print('  format    Format/prettify TOON files');
  print('  validate  Validate TOON syntax and structure');
  print('  convert   Convert between JSON and TOON formats');
  print('  minify    Minify TOON files for compact output\n');
  print('Global options:');
  print(parser.usage);
  print('\nRun "toon <command> --help" for more information on a command.');
}

Future<void> handleFormat(ArgResults command) async {
  if (command.rest.isEmpty) {
    print('Error: No input file specified');
    print('Usage: toon format [options] <file>');
    exit(1);
  }

  final inputPath = command.rest[0];
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  final content = await file.readAsString();
  final indent = int.parse(command['indent']);
  final checkOnly = command['check'];
  final writeToFile = command['write'];
  final outputPath = command['output'];

  try {
    // Decode and re-encode with formatting
    final decoded = toon.decode(content);
    final options = ToonOptions(indent: indent, compactOutput: false);
    final formatted = ToonCodec(options: options).encode(decoded);

    if (checkOnly) {
      if (content.trim() == formatted.trim()) {
        print('✓ $inputPath is already formatted');
        exit(0);
      } else {
        print('✗ $inputPath needs formatting');
        exit(1);
      }
    }

    if (writeToFile || outputPath != null) {
      final output = File(outputPath ?? inputPath);
      await output.writeAsString(formatted);
      print('✓ Formatted: ${output.path}');
    } else {
      print(formatted);
    }
  } catch (e) {
    print('Error formatting file: $e');
    exit(1);
  }
}

Future<void> handleValidate(ArgResults command) async {
  if (command.rest.isEmpty) {
    print('Error: No input file specified');
    print('Usage: toon validate [options] <file>');
    exit(1);
  }

  final inputPath = command.rest[0];
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  final content = await file.readAsString();
  final strict = command['strict'];
  final verbose = command['verbose'];

  final options = strict ? ToonOptions.strict : ToonOptions.defaults;
  final validator = ToonValidator(options: options);

  try {
    final errors = validator.validate(content);

    if (errors.isEmpty) {
      print('✓ $inputPath is valid TOON format');
      exit(0);
    } else {
      print('✗ Validation failed: ${errors.length} issue(s) found\n');
      for (final error in errors) {
        print('[${error.severity}] ${error.message}');
        if (verbose) {
          print('  Location: ${error.location}');
          final excerpt = error.sourceExcerpt;
          if (excerpt != null) {
            print(
              '  Context:\n${excerpt.split('\n').map((l) => '    $l').join('\n')}',
            );
          }
        }
        print('');
      }
      exit(1);
    }
  } catch (e) {
    print('Error validating file: $e');
    exit(1);
  }
}

Future<void> handleConvert(ArgResults command) async {
  if (command.rest.isEmpty) {
    print('Error: No input file specified');
    print('Usage: toon convert --from <format> --to <format> [options] <file>');
    exit(1);
  }

  final inputPath = command.rest[0];
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  final content = await file.readAsString();
  final from = command['from'];
  final to = command['to'];
  final outputPath = command['output'];
  final pretty = command['pretty'];

  if (from == to) {
    print('Error: Source and target formats are the same');
    exit(1);
  }

  try {
    String output;

    if (from == 'json' && to == 'toon') {
      // JSON to TOON
      final data = json.decode(content);
      final options = pretty ? ToonOptions.pretty : ToonOptions.compact;
      output = ToonCodec(options: options).encode(data);
    } else if (from == 'toon' && to == 'json') {
      // TOON to JSON
      final data = toon.decode(content);
      final encoder = pretty ? JsonEncoder.withIndent('  ') : JsonEncoder();
      output = encoder.convert(data);
    } else {
      print('Error: Invalid conversion: $from to $to');
      exit(1);
    }

    if (outputPath != null) {
      final outputFile = File(outputPath);
      await outputFile.writeAsString(output);
      print('✓ Converted: $from → $to');
      print('  Output: ${outputFile.path}');
    } else {
      print(output);
    }
  } catch (e) {
    print('Error converting file: $e');
    exit(1);
  }
}

Future<void> handleMinify(ArgResults command) async {
  if (command.rest.isEmpty) {
    print('Error: No input file specified');
    print('Usage: toon minify [options] <file>');
    exit(1);
  }

  final inputPath = command.rest[0];
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  final content = await file.readAsString();
  final outputPath = command['output'];

  try {
    // Decode and re-encode with compact options
    final decoded = toon.decode(content);
    final minified = ToonCodec(options: ToonOptions.compact).encode(decoded);

    final originalSize = content.length;
    final minifiedSize = minified.length;
    final savings = ((originalSize - minifiedSize) / originalSize * 100)
        .toStringAsFixed(1);

    if (outputPath != null) {
      final outputFile = File(outputPath);
      await outputFile.writeAsString(minified);
      print('✓ Minified: ${outputFile.path}');
      print('  Original: $originalSize bytes');
      print('  Minified: $minifiedSize bytes');
      print('  Savings: $savings%');
    } else {
      print(minified);
    }
  } catch (e) {
    print('Error minifying file: $e');
    exit(1);
  }
}
