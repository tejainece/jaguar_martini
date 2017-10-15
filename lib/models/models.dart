library jaguar.martini.models;

import 'package:meta/meta.dart';

part 'post_meta.dart';
part 'site_meta.dart';

/// Interface for a page
abstract class AnyPage {
  Site get site;
}

/// Model for a single article
class SinglePage implements AnyPage {
  /// Metadata of the page picked from front-matter
  final PostMeta meta;

  /// The processed content itself
  final String content;

  final List<Tag> tags = [];

  final List<Category> categories = [];

  /// The approximate number of words in the content
  // TODO int fuzzyWordCount;

  /// Next article in site ordered by published date
  SinglePage next;

  /// Previous article in site ordered by published date
  SinglePage prev;

  /// Next article in section ordered by published date
  SinglePage nextInSection;

  /// Previous article in section ordered by published date
  SinglePage prevInSection;

  /// Next article in series ordered by published date
  ///
  /// Returns null if the article is not in a section
  // TODO Page nextInSeries;

  /// Previous article in series ordered by published date
  ///
  /// Returns null if the article is not in a section
  // TODO Page prevInSeries;

  // TODO pages

  // TODO permalink

  // TODO plain

  // TODO plain words

  // TODO reading time

  /// The section this page belongs to
  final Section section;

  // TODO summary

  // TODO table of contents

  // TODO int wordCount

  /// The [Site] this [SinglePage] belongs to
  Site get site => section.site;

  SinglePage(this.section, this.meta, this.content);
}

/// Model for a page that displays list of articles
abstract class ListPage implements AnyPage {
  List<SinglePage> get pages;
}

class Section implements ListPage {
  /// The [Site] this [Section] belongs to
  final Site site;

  /// Name of the section
  final String name;

  /// Articles that belong to this section
  final List<SinglePage> pages = <SinglePage>[];

  /// Tags in the section
  final List<Tag> tags = <Tag>[];

  /// Categories in the section
  final List<Category> categories = <Category>[];

  /// Default constructor to create an instance of [Section] with given [site]
  /// and [name]
  Section(this.site, this.name);
}

/// Model of a page for a tag
class Tag implements ListPage {
  /// The [Site] this [Tag] belongs to
  final Site site;

  /// Name of the tag
  final String name;

  /// Articles belonging to this tag
  final List<SinglePage> pages = [];

  /// Default constructor to create an instance of [Tag] with given [site]
  /// and [name]
  Tag(this.site, this.name);
}

/// Model of a page for category
class Category implements ListPage {
  /// The [Site] this [Category] belongs to
  final Site site;

  /// Name of the category
  final String name;

  /// Articles belonging to this category
  final List<SinglePage> pages = [];

  /// Default constructor to create an instance of [Category] with given [site]
  /// and [name]
  Category(this.site, this.name);
}

/// Model of the whole site
class Site implements AnyPage {
  /// Site meta data
  final SiteMetaData meta;

  /// Models of sections in the site
  final Map<String, Section> sections = <String, Section>{};

  /// Model of all articles in the site
  final List<SinglePage> pages = <SinglePage>[];

  /// Model for all tags in the site
  final Map<String, Tag> tags = <String, Tag>{};

  /// Model for all categories in the site
  final Map<String, Category> categories = <String, Category>{};

  /// Default constructor to create an instance of [Site] with given [meta]
  Site(this.meta);

  /// A dummy to comply to [AnyPage] interface
  Site get site => this;
}
