library jaguar.martini.models;

import 'package:jaguar/jaguar.dart';
import 'package:meta/meta.dart';

part 'post_meta.dart';
part 'site_meta.dart';

/// Interface for a page
abstract class AnyPage {
  Site get site;

  /// Permanent link of this page
  String get permalink =>
      PathUtils.join([site.meta.baseURL, permalinkRel], absolute: true);

  /// Permanent link of this page
  String get permalinkRel;
}

/// Model for a single article
class SinglePage extends AnyPage {
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

  /// Permanent link of this page
  String get permalinkRel {
    if (meta.url is String) {
      return meta.url;
    }

    if (site.meta.sectionPermalinks.containsKey(section.name)) {
      return makeRelPermalink(site.meta.sectionPermalinks[section.name]);
    }

    if (site.meta.permalink is String) {
      return makeRelPermalink(site.meta.permalink);
    }

    return PathUtils.join(meta.slugs);
  }

  String makeRelPermalink(String permalinkFormat) {
    final List<String> segs = splitPathToSegments(permalinkFormat);

    final output = <String>[];

    for (String seg in segs) {
      if (!seg.startsWith(':')) {
        output.add(seg);
      } else {
        switch (seg) {
          case ':year':
            output.add(meta.date.year.toString());
            break;
          case ':month':
            if (meta.date.month < 10) {
              output.add(meta.date.month.toString());
            } else {
              output.add('0' + meta.date.month.toString());
            }
            break;
          case ':monthname':
            output.add(monthNames[meta.date.month - 1]);
            break;
          case ':day':
            if (meta.date.day < 10) {
              output.add(meta.date.day.toString());
            } else {
              output.add('0' + meta.date.day.toString());
            }
            break;
          case ':weekday':
            output.add(meta.date.weekday.toString());
            break;
          case ':weekdayname':
            output.add(dayNames[meta.date.weekday - 1]);
            break;
          case ':yearday':
            int days =
                meta.date.difference(new DateTime(meta.date.year, 1, 1)).inDays;
            if (days < 10) {
              output.add('00' + days.toString());
            } else if (days < 100) {
              output.add('0' + days.toString());
            } else {
              output.add(days.toString());
            }
            break;
          case ':section':
            output.add(section.name);
            break;
          case ':title':
            output.add(meta.title);
            break;
          case ':slug':
            output.add(meta.title);
            break;
        }
      }
    }

    return PathUtils.join(output);
  }

  // Weekday constants that are returned by [weekday] method:
  static const dayNames = const <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Month constants that are returned by the [month] getter.
  static const monthNames = const <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static int compare(SinglePage a, SinglePage b) =>
      a.meta.date.compareTo(b.meta.date);

  static int compareAlphabetic(SinglePage a, SinglePage b) =>
      a.meta.title.compareTo(b.meta.title);
}

/// Model for a page that displays list of articles
abstract class ListPage extends AnyPage {
  List<SinglePage> get pages;
}

class Section extends ListPage {
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

  /// Permanent link of this page
  String get permalinkRel => PathUtils.join([name]);
}

/// Model of a page for a tag
class Tag extends ListPage {
  /// The [Site] this [Tag] belongs to
  final Site site;

  /// Name of the tag
  final String name;

  /// Articles belonging to this tag
  final List<SinglePage> pages = [];

  /// Default constructor to create an instance of [Tag] with given [site]
  /// and [name]
  Tag(this.site, this.name);

  /// Permanent link of this page
  String get permalinkRel => PathUtils.join(['tags', name]);
}

/// Model of a page for category
class Category extends ListPage {
  /// The [Site] this [Category] belongs to
  final Site site;

  /// Name of the category
  final String name;

  /// Articles belonging to this category
  final List<SinglePage> pages = [];

  /// Default constructor to create an instance of [Category] with given [site]
  /// and [name]
  Category(this.site, this.name);

  /// Permanent link of this page
  String get permalinkRel => PathUtils.join(['category', name]);
}

/// Model of the whole site
class Site extends ListPage {
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

  /// Permanent link of this page
  String get permalinkRel => '/';
}

class PathUtils {
  static int countLeadingSlashes(List<int> chars) {
    for (int i = 0; i < chars.length; i++) {
      if (chars[i] != 47) return i;
    }

    return chars.length;
  }

  static int countTrailingSlashes(List<int> chars) {
    for (int i = 0; i < chars.length; i++) {
      if (chars[chars.length - i - 1] != 47) return chars.length - i;
    }

    return 0;
  }

  static String join(List<String> segs, {bool absolute: false}) {
    final newSegs = <String>[];

    for (String seg in segs) {
      if (seg.isEmpty) continue;

      final chars = seg.codeUnits;
      final int start = countLeadingSlashes(chars);
      if (start == chars.length) continue;
      final int end = countTrailingSlashes(chars);
      newSegs.add(seg.substring(start, end));
    }

    return (!absolute ? '/' : '') + newSegs.join('/');
  }
}
