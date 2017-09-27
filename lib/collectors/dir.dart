import 'dart:io';
import 'dart:async';
import 'package:jaguar_hugo/core/core.dart';

/// Reads all posts from specified directory and aggregates them
class DirPostCollector {
  final Directory _dir;

  DirPostCollector(this._dir);



  /// performs the collection
  Stream<CollectedPost> collect() {

    //TODO
  }
}