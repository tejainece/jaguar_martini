library jaguar.gencon;

import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_martini/jaguar_martini.dart';

/// Caches the responses as they are generated and serves the cached requests
class GeneratedHandler implements RequestHandler {
  final String base;

  final Processor processor;

  GeneratedHandler(this.processor, {this.base: ''});

  FutureOr<Response> handleRequest(Context ctx, {String prefix: ''}) {
    if (ctx.method != 'GET') return null;
    try {
      return processor.cache.read(prefix + ctx.path);
    } catch (e) {
      return null;
    }
  }
}
