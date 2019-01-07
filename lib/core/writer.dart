part of jaguar.martini.core;

/// Contains logic to produce output formats (HTML, RSS, etc) from models
class _Writer {
  final SiteRenderer site;

  /// Map of section name to section's writer
  Map<String, SectionRenderer> get sections => site.sections;

  _Writer(this.site);

  FutureOr<List<String>> siteIndex(Site info) => site.index(info);

  FutureOr<List<String>> siteCategory(Category cat) => site.categories(cat);

  FutureOr<List<String>> siteTag(Tag tag) => site.tags(tag);

  FutureOr<List<String>> sectionIndex(Section info) {
    if (sections.containsKey(info.name)) {
      return sections[info.name].index(info);
    }
    return site.defaultSectionRenderer.index(info);
  }

  FutureOr<String> sectionSingle(String section, SinglePage info) {
    if (sections.containsKey(section)) {
      return sections[section].single(info);
    }
    return site.defaultSectionRenderer.single(info);
  }

  FutureOr<List<String>> sectionCategory(String section, Category cat) {
    if (sections.containsKey(section)) {
      return sections[section].categories(cat);
    }
    return site.defaultSectionRenderer.categories(cat);
  }

  FutureOr<List<String>> sectionTag(String section, Tag tag) {
    if (sections.containsKey(section)) {
      return sections[section].tags(tag);
    }
    return site.defaultSectionRenderer.tags(tag);
  }
}
