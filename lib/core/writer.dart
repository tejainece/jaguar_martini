part of jaguar.martini.core;

/// Contains logic to produce output formats (HTML, RSS, etc) from models
class _Renderer {
  final SiteRenderer site;

  /// Map of section name to section's writer
  Map<String, SectionRenderer> get sections => site.sections;

  _Renderer(this.site);

  FutureOr<List<String>> siteIndex(Site info) => site.index(info);

  FutureOr<List<String>> siteCategory(Category cat) => site.categories(cat);

  FutureOr<List<String>> siteTag(Tag tag) => site.tags(tag);

  FutureOr<List<String>> sectionIndex(Section info) {
    if (sections.containsKey(info.name)) {
      return sections[info.name].index(info);
    }
    return site.sectionIndex(info);
  }

  FutureOr<String> sectionSingle(String section, SinglePage info) {
    if (sections.containsKey(section)) {
      return sections[section].single(info);
    }
    return site.sectionSingle(info);
  }

  FutureOr<List<String>> sectionCategory(String section, Category cat) {
    if (sections.containsKey(section)) {
      return sections[section].categories(cat);
    }
    return site.sectionCategories(cat);
  }

  FutureOr<List<String>> sectionTag(String section, Tag tag) {
    if (sections.containsKey(section)) {
      return sections[section].tags(tag);
    }
    return site.sectionTags(tag);
  }
}

abstract class TopRenderer {
  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> index(ListPage page);

  FutureOr<List<String>> tags(Tag tags);

  FutureOr<List<String>> categories(Category categories);
}
