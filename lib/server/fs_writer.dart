library jaguar.fs_writer;

import 'dart:io';
import 'dart:async';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:path/path.dart' as p;

/// Writer the site to file system
class FsWriter {
  final Directory out;

  final Directory statics;

  final Builder builder;

  FsWriter(this.builder, this.out, {this.statics});

  Future write() async {
    if(await out.exists()) {
      await out.delete(recursive: true);
    }
    Map<String, String> compiled = await builder.compile();
    final futures = <Future>[];
    for (String path in compiled.keys) {
      futures.add(writeFile(path, compiled[path]));
    }
    if (statics != null && await statics.exists()) {
      futures.add(_copyDir(statics.path, p.join(out.path, 'static')));
    }
    await Future.wait(futures);
  }

  Future writeFile(String path, String content) async {
    path = p.join(
        out.path, p.joinAll(p.split(path)..removeWhere((s) => s == '/')));
    FileSystemEntityType type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.DIRECTORY) {
      await new Directory(path).delete(recursive: true);
    } else if (type == FileSystemEntityType.FILE ||
        type == FileSystemEntityType.LINK) {
      await new File(path).delete(recursive: true);
    }

    File file = await new File(path).create(recursive: true);
    await file.writeAsString(content);
    print('Written file $path ...');
  }
}

Future _copyDir(String src, String dest) async {
  final srcDir = new Directory(src);
  if (!await srcDir.exists()) {
    throw new Exception('Directory does not exist: $src!');
  }
  final dstDir = new Directory(dest);
  if (!await dstDir.exists()) {
    await dstDir.create(recursive: true);
  }

  await for (FileSystemEntity element in srcDir.list()) {
    String newPath = p.join(dest, p.split(element.path).last);
    if (element is File) {
      await new File(newPath).openWrite().addStream(element.openRead());
    } else if (element is Directory) {
      await _copyDir(element.path, newPath);
    }
  }
}
