import 'dart:io';
import 'dart:async';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'package:rate_limit/rate_limit.dart';
import 'package:jaguar_martini/collectors/collectors.dart';
import 'package:jaguar_martini/models/models.dart';

/// Reads all posts from specified directory and aggregates them
class DirPostCollector implements PostCollector {
  final Directory _dir;

  DirPostCollector(this._dir);

  /// Path of the directory
  String get path => _dir.path;

  StreamController<Null> _changeMan = new StreamController<Null>();

  Stream<Null> get onChange => _changeMan.stream.transform<Null>(
      new Throttler<Null>(const Duration(seconds: 5), trailing: false));

  final _subs = <String, StreamSubscription>{};

  bool _working = false;

  /// Performs the collection
  Future<Stream<CollectedPost>> collect() async {
    while (_working) await new Future.delayed(new Duration(milliseconds: 500));
    _working = true;
    for (final sc in _subs.values) {
      await sc.cancel();
    }
    _subs.clear();

    final controller = new StreamController<CollectedPost>();

    _collectDir(_dir, controller).then((_) async {
      controller.close();
    });

    _working = false; // TODO must also be freed when there is an exception
    return controller.stream;
  }

  Future _collectDir(
      Directory dir, StreamController<CollectedPost> controller) async {
    final items = await dir.list();

    await for (final FileSystemEntity item in items) {
      if (item is File) {
        final CollectedPost post = await process(item);
        if (post != null) controller.add(post);
      } else if (item is Directory) {
        await _collectDir(item, controller);
      }
    }

    _subs[dir.path] = dir.watch().listen((f) {
      _changeMan.add(null);
    });
  }

  Future<CollectedPost> process(File file) async {
    if (p.extension(file.path) != '.md') return null;

    final List<String> lines = await file.readAsLines();

    final int sepIdx = lines.indexOf('+++');

    if (sepIdx == -1) return null;

    Map<String, dynamic> yaml;

    final slugs = getSlug(_dir.path, file.path);

    try {
      yaml = loadYaml(lines.sublist(0, sepIdx).join('\n'));
    } catch (e) {
      final String path = p.joinAll(slugs) ?? file.path;
      throw CollectorError.frontMatter(path);
    }

    slugs[slugs.length - 1] = p.basenameWithoutExtension(slugs.last);

    final PostMeta meta = new PostMeta.yaml(slugs.first, yaml, slugs);
    return new CollectedPost(meta, lines.sublist(sepIdx + 1).join('\n'));
  }

  static List<String> getSlug(String contentPath, String postPath) {
    final List<String> cP = p.split(contentPath);
    final List<String> pP = p.split(postPath);

    if (pP.length < cP.length) return null;

    return pP.sublist(cP.length);
  }
}
