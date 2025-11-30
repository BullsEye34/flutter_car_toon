/// Builder entry point for TOON code generation
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'toon_generator.dart';

/// Creates the builder for TOON serialization code generation
Builder toonSerializable(BuilderOptions options) {
  return PartBuilder([ToonGenerator()], '.toon.dart');
}
