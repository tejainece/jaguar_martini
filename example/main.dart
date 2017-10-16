// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_static_file/jaguar_static_file.dart';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:jaguar_martini/collectors/dir.dart';

import 'logic/shortcodes/gist.dart';
import 'logic/layouts/layouts.dart';

const siteMeta = const SiteMetaData(
    title: 'Geek went freak!', baseURL: 'http://localhost:8080');

main(List<String> arguments) async {
  final postCollector = new DirPostCollector(new Directory('./content'));
  final processor = new Processor(siteMeta, new FallbackWriter())
    ..addShortcode(const GistShortCode())
    ..add(postCollector)
    ..start();

  final jaguar = new Jaguar();
  jaguar.addApi(new GeneratedHandler(processor));
  jaguar.addApi(new StaticFileHandler('/static/*', new Directory('./static')));
  await jaguar.serve();
}
