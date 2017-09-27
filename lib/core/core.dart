import 'dart:async';
import 'package:jaguar/jaguar.dart';

// Serves the static site
Future serve() async {
  final server = new Jaguar();

  // TODO

  await server.serve();
}

/// Reads all posts from all sources and aggregates them
abstract class PostCollector {
  /// performs the collection
  Stream<CollectedPost> collect();
}

class PostMeta {
  /// Title of the post
  String title;

  /// Description for the post
  String description;

  /// Categories
  List<String> categories;

  /// Tags
  List<String> tags;

  /// Time when the post was created
  DateTime createdAt;

  /// Is this post still a draft?
  bool draft;
}

class CollectedPost {
  /// Metadata of the post
  PostMeta meta;

  /// Content of the post
  String mdContent;
}

abstract class Shortcode {
  String get name;

  String transform(List<String> params, String content);
}

class Engine {
  final _shortcodes = <String, Shortcode>{};

  void addShortcode(Shortcode shortcode) {
    // TODO check name of shortcode

    if (_shortcodes.containsKey(shortcode.name)) {
      throw new ArgumentError.value(shortcode, 'shortcode',
          'Shortcode with name ${shortcode.name} already exists!');
    }

    _shortcodes[shortcode.name] = shortcode;
  }
}