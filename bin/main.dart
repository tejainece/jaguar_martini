// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_martini/gencon/gencon.dart';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:jaguar_martini/collectors/dir.dart';

class FallbackWriter implements SectionWriter {
  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page) {
    return '''
<html>
  <head></head>
  <body>
    ${page.content}
  </body>
</html>
    ''';
  }

  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<String> list(ListPage page) {
    // TODO
    throw new UnimplementedError();
  }
}

main(List<String> arguments) async {
  final d = new Directory('./content');
  final c = new DirPostCollector(d);
  final processor = new Processor(new FallbackWriter())
    ..add(c)
    ..start();

  final jaguar = new Jaguar();
  jaguar.addApi(new GeneratedHandler(processor));
  await jaguar.serve();
}
