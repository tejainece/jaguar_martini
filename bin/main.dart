// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:jaguar_martini/collectors/dir.dart';

main(List<String> arguments) async {
  final d = new Directory('./content');
  final c = new DirPostCollector(d);
  final processor = new Processor()
    ..add(c)
    ..start();
}
