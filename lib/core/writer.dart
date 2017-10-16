part of jaguar.martini.core;

/// Contains logic to produce output formats (HTML, RSS, etc) from models
class Writer {
  /// Fallback section renderer
  ///
  /// Used when [sections] does not have an entry for the rendered section
  final SectionWriter fallback;

  /// Map of section name to section's writer
  final Map<String, SectionWriter> sections;

  Writer(this.fallback, {this.sections: const {}});
}

/// Contains logic to produce output formats (HTML, RSS, etc) from models for
/// a section
abstract class SectionWriter {
  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page);

  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> list(ListPage page);
}
