import 'dart:async';
import 'package:jaguar_martini/models/models.dart';
import 'package:jaguar_martini/shortcode/shortcode.dart';

/// Contains logic to produce output formats (HTML, RSS, etc) from
/// models for a section
abstract class SectionRenderer {
  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> index(Section page);

  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page);

  FutureOr<List<String>> tags(Tag tags);

  FutureOr<List<String>> categories(Category categories);
}

abstract class SiteRenderer {
  List<ShortCode> get shortcodes;

  Map<String, SectionRenderer> get sections;

  FutureOr<List<String>> index(Site site);

  FutureOr<List<String>> tags(Tag tags);

  FutureOr<List<String>> categories(Category categories);

  FutureOr<List<String>> sectionIndex(Section info);

  FutureOr<String> sectionSingle(SinglePage info);

  FutureOr<List<String>> sectionCategories(Category cat);

  FutureOr<List<String>> sectionTags(Tag tag);
}
