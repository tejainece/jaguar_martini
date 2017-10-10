import 'package:jaguar_martini/core/core.dart';

class SinglePage {
  /// Metadata of the page picked from front-matter
  final PostMeta meta;

  /// The processed content itself
  final String content;

  final List<Tag> tags = [];

  final List<Category> categories = [];

  /// The approximate number of words in the content
  // TODO int fuzzyWordCount;

  final bool isHome;

  SinglePage next;

  SinglePage prev;

  SinglePage nextInSection;

  SinglePage prevInSection;

  // TODO Page nextInSeries;

  // TODO Page nextInSeries;

  // TODO pages

  // TODO permalink

  // TODO plain

  // TODO plain words

  // TODO reading time

  /// The section this page belongs to
  final Section section;

  // TODO summary

  // TODO table of contents

  /// The URL for the page relative to the web root. Note that a url set directly
  /// in front matter overrides the default relative URL for the rendered page.
  final String url;

  // TODO int wordCount

  SinglePage(
    this.section,
    this.meta,
    this.content,
    this.url, {
    this.isHome: false,
  });
}

class Section {
  final String name;

  final List<SinglePage> pages = <SinglePage>[];

  final List<Tag> tags = <Tag>[];

  final List<Category> categories = <Category>[];

  Section(this.name);
}

class Tag {
	final String name;

	final List<SinglePage> pages = [];

	Tag(this.name);
}

class Category {
	final String name;

	final List<SinglePage> pages = [];

	Category(this.name);
}

/// A page that displays list of posts
abstract class ListPage {
  List<SinglePage> get pages;

  List<Tag> get tags;

  List<Category> get categories;
}

/// Contains the data for the whole site
class Site {
  final Map<String, Section> sections = <String, Section>{};

  final List<SinglePage> pages = <SinglePage>[];

  final Map<String, Tag> tags = <String, Tag>{};

  final Map<String, Category> categories = <String, Category>{};
}
