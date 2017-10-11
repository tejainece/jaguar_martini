part of jaguar.martini.core;

class PostMeta {
  // The section the post is in
  final String section;

  /// Title of the post
  final String title;

  /// Description for the post
  final String description;

  final String linkTitle;

  /// The URL for the page relative to the web root. Note that a url set directly
  /// in front matter overrides the default relative URL for the rendered page.
  final String url;

  /// Categories
  final List<String> categories;

  /// Tags
  final List<String> tags;

  final List<String> slugs;

  /// Time when the post was created
  final DateTime createdAt;

  /// Is this post still a draft?
  final bool draft;

  /// Assigned weight (in the front matter) to this content, used in sorting.
  final int weight;

  // TODO revisions

  final Map<String, dynamic> params;

  PostMeta(this.section, this.title, this.slugs, this.createdAt,
      {this.description,
      this.linkTitle,
      this.url,
      this.categories,
      this.tags,
      this.draft,
      this.weight,
      this.params});

  factory PostMeta.yaml(
      String section, Map<String, dynamic> yaml, List<String> slugs) {
    final String title = yaml['title'];
    final String description = yaml['description'];
    final List<String> categories = yaml['categories'];
    final List<String> tags = yaml['tags'];
    final String slug = yaml['slug'];
    final String url = yaml['url'];
    final DateTime createdAt = yaml['createdAt'];
    final bool draft = yaml['draft'];
    final String linkTitle = yaml['linkTitle'];
    final int weight = int.parse(yaml['weight'] ?? '', onError: (_) => null);

    // TODO check types of these

    if (slug is String) {
      slugs = slug.split('/');
    }

    // TODO params
    return new PostMeta(section, title, slugs, createdAt ?? new DateTime.now(),
        description: description ?? '',
        linkTitle: linkTitle,
        url: url ?? ('/' + (slugs.join('/') + '.html')),
        categories: categories ?? <String>[],
        tags: tags ?? <String>[],
        draft: draft ?? true,
        weight: weight);
  }
}
