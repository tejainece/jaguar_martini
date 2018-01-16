part of jaguar.martini.core;

typedef FutureOr<String> SiteIndexRenderer(Site page);

typedef FutureOr<String> SiteTagsRenderer(Tag page);

typedef FutureOr<String> SiteCategoriesRenderer(Category page);

typedef FutureOr<String> SingleRenderer(SinglePage page);

/// Contains logic to produce output formats (HTML, RSS, etc) from models
class Writer {
  final SiteWriter site;

  /// Fallback section renderer
  ///
  /// Used when [sections] does not have an entry for the rendered section
  final SectionWriter fallback;

  /// Map of section name to section's writer
  final Map<String, SectionWriter> sections;

  Writer(this.fallback, {this.sections: const {}, this.site});

  Future<List<String>> renderSiteIndex(Site info) {
    final TopWriter w = site ?? fallback;
    return w.index(info);
  }

  Future<List<String>> renderSectionIndex(Section info) {
    final SectionWriter w = sections[info.name] ?? fallback;
    return w.index(info);
  }

  Future<String> renderSectionSingle(String section, SinglePage info) {
    final SectionWriter w = sections[section] ?? fallback;
    return w.single(info);
  }
}

abstract class TopWriter {
  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> index(ListPage page);

  FutureOr<String> tags(Tag tags);

  FutureOr<String> categories(Category categories);
}

/// Contains logic to produce output formats (HTML, RSS, etc) from models for
/// a section
abstract class SectionWriter implements TopWriter {
  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> index(covariant Section page);

  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page);

  FutureOr<String> tags(Tag tags);

  FutureOr<String> categories(Category categories);
}

abstract class SiteWriter implements TopWriter {
  FutureOr<List<String>> index(covariant Site site);

  FutureOr<String> tags(Tag tags);

  FutureOr<String> categories(Category categories);
}
