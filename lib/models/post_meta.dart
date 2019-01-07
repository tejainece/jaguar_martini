part of jaguar.martini.models;

class PostMeta {
  // The section the post is in
  final String section;

  /// Title of the post
  final String title;

  /// Description for the post
  final String description;

  final String linkTitle;

  final String permalink;

  /// The URL for the page relative to the web root. Note that a url set directly
  /// in front matter overrides the default relative URL for the rendered page.
  final String url;

  /// Categories
  final List<String> categories;

  /// Tags
  final List<String> tags;

  final List<String> slugs;

  /// Time when the post was created
  final DateTime date;

  /// Is this post still a draft?
  final bool draft;

  /// Assigned weight (in the front matter) to this content, used in sorting.
  final int weight;

  // TODO revisions

  final Map<String, dynamic> params;

  PostMeta(this.section, this.title, this.slugs, this.date,
      {this.description,
      this.linkTitle,
      this.permalink,
      this.url,
      this.categories,
      this.tags,
      this.draft,
      this.weight,
      this.params});

  factory PostMeta.yaml(String section, Map yaml, List<String> slugs) {
    final String title = yaml['title'];
    final String description = yaml['description'];
    final List<String> categories =
        (yaml['categories'] as List)?.cast<String>();
    final List<String> tags = (yaml['tags'] as List)?.cast<String>();
    final String slug = yaml['slug'];
    final String url = yaml['url'];
    final String permalink = yaml['permalink'];
    final String date = yaml['date'];
    final bool draft = yaml['draft'];
    final String linkTitle = yaml['linkTitle'];
    final int weight = yaml['weight'];

    // TODO check types of these

    if (slug is String) {
      slugs = slug.split('/');
    }

    DateTime parsedDate = new DateTime.now();
    if (date is String) {
      try {
        parsedDate = DateTime.parse(yaml['date']);
      } catch (e) {
        // Do nothing!
      }
    }

    // TODO params
    return new PostMeta(section, title, slugs, parsedDate,
        description: description ?? '',
        linkTitle: linkTitle,
        url: url,
        permalink: permalink,
        categories: categories ?? <String>[],
        tags: tags ?? <String>[],
        draft: draft ?? true,
        weight: weight);
  }
}

class CollectedPost {
  /// Metadata of the post
  PostMeta meta;

  /// Content of the post
  String content;

  CollectedPost(this.meta, this.content);
}
