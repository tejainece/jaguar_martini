library jaguar.martini.core;

import 'dart:async';
import 'dart:convert';
import 'package:jaguar/jaguar.dart';
import 'package:markd/markdown.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:jaguar_martini/collectors/collectors.dart';

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
}
