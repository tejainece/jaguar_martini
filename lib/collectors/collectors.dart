import 'dart:async';
import 'package:jaguar_martini/jaguar_martini.dart';

/// Reads all posts from all sources and aggregates them
abstract class PostCollector {
  Stream<Null> get onChange;

  /// performs the collection
  Future<Stream<CollectedPost>> collect();
}

class CollectorError {
  final String path;

  final String message;

  const CollectorError(this.path, this.message);

  static CollectorError frontMatter(String path) =>
      new CollectorError(path, 'Invalid front matter!');
}
