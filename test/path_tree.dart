// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('PathTree', () {
    test('calculate', () {
      print(p.url.join(p.url.separator, 'tags', 'arm'));
    });
  });
}
