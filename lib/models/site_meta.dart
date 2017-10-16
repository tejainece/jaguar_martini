part of jaguar.martini.models;

class SiteMetaData {
  /// Title of the site
  final String title;

  /// Description of the site
  final String description;

  /// Base URL of the site
  final String baseURL;

  /// Authors of the site
  final List<String> authors;

  /// Copyright of the site
  final String copyright;

  /// Default permalink format
  final String permalink;

  /// Permalink format per section
  final Map<String, String> sectionPermalinks;

  /// Additional params
  final Map<String, dynamic> params;

  const SiteMetaData(
      {@required this.title,
      @required this.baseURL,
      this.description,
      this.authors: const <String>[],
      this.copyright,
      this.permalink,
      this.sectionPermalinks: const {},
      this.params: const <String, dynamic>{}});

  factory SiteMetaData.yaml(Map<String, dynamic> yaml) {
    final String title = yaml['title'];
    String baseURL = yaml['baseURL'];
    List<String> authors = yaml['authors'] ?? <String>[];
    String copyright = yaml['copyright'];
    Map<String, dynamic> params = yaml['params'] ?? <String, dynamic>{};

    // TODO validate

    return new SiteMetaData(
        title: title,
        baseURL: baseURL,
        authors: authors,
        copyright: copyright,
        params: params);
  }
}
