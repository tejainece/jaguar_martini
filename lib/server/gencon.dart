library jaguar.gencon;

import 'dart:async';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:jaguar_cache/jaguar_cache.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:path/path.dart' as p;

/// Caches the responses as they are generated and serves the cached requests
class GeneratedHandler implements RequestHandler {
  final String base;

  final Processor processor;

  GeneratedHandler(this.processor, {this.base: ''});

  FutureOr<Response> handleRequest(Context ctx, {String prefix: ''}) {
    if (ctx.method != 'GET') return null;

    final String path = prefix + '/' + p.joinAll(ctx.pathSegments);
    Response ret;
    try {
      ret = processor.cache.read(path);
    } catch (e) {
      if (e != cacheMiss) rethrow;
    }

    if (ret != null) return ret;

    try {
      ret = processor.cache.read(path + '/index.html');
    } catch (e) {
      if (e != cacheMiss) rethrow;
    }

    return ret;
  }
}

class ServeCommand extends Command {
  Cli cli;

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

class Cli {
  final Processor processor;

  Cli(this.processor);
}

