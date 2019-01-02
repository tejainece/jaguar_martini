library jaguar.gencon;

import 'dart:async';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:path/path.dart' as p;

/// Caches the responses as they are generated and serves the cached requests
class GeneratedHandler {
  final String base;

  final Builder builder;

  final cache = new InMemoryCache<Response>(null);

  GeneratedHandler(this.builder, {this.base: ''}) {

  }

  StreamSubscription _sub;

  void start() {
    if(_sub != null) return;
    builder.watcher.listen(_updateCache);
  }

  Future close() async {
    await _sub.cancel();
    _sub = null;
  }

  void _updateCache(Map<String, String> outputs) {
    cache.clear();

    for (final String path in outputs.keys) {
      cache.upsert(
          path,
          new Response(utf8.encode(outputs[path]))
            ..headers.charset = 'utf8'
            ..headers.mimeType = 'text/html');
    }
  }

  void call(Context ctx) {
    final String path = ctx.path;

    try {
      ctx.response = cache.read(path);
    } catch (e) {
      if (e != cacheMiss) rethrow;
    }

    if (ctx.response != null) return;

    try {
      ctx.response = cache.read(path + '/index.html');
    } catch (e) {
      if (e != cacheMiss) rethrow;
    }

    return;
  }
}

class ServeCommand extends Command {
  ServeCommand() {
    argParser.addOption('host',
        abbr: 'h',
        defaultsTo: 'localhost',
        help: 'Host on which content shall be served!');
    argParser.addOption('port',
        abbr: 'p',
        defaultsTo: '8000',
        help: 'Port on which content shall be served!');
  }

  @override
  final String name = 'serve';

  @override
  final String description = 'Serves static website';

  @override
  run() async {
    // TODO
  }
}

