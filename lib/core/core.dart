library jaguar.martini.core;

import 'dart:async';
import 'dart:convert';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:markd/markdown.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:jaguar_martini/collectors/collectors.dart';
import 'package:jaguar_martini/models/models.dart';

part 'metadata.dart';
part 'processor.dart';

// Serves the static site
Future serve() async {
  final server = new Jaguar();

  // TODO

  await server.serve();
}

class CollectedPost {
  /// Metadata of the post
  PostMeta meta;

  /// Content of the post
  String content;

  CollectedPost(this.meta, this.content);
}

abstract class Shortcode {
  String get name;

  String transform(List<String> params, String content);

  static bool isTag(String line) {
    if (!line.startsWith(r'{{<')) return false;
    if (!line.endsWith(r'>}}')) return false;

    return true;
  }

  static bool isEndTagNamed(String line, String name) {
    return line.startsWith(new RegExp(r'{{<[ \t]*/' + name + r'[ \t]*>}}$'));
  }

  static bool isSingleLineTag(String line) {
    if (!line.startsWith(r'{{<')) return false;
    if (!line.endsWith('/>}}')) return false;

    return true;
  }

  static String getName(String line) {
    // TODO
  }
}
