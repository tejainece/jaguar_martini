part of jaguar.martini.core;

class Processor {
  final List<PostCollector> _collectors = [];

  final _shortcodes = <String, Shortcode>{};

  Processor();

  void add(PostCollector c) => _collectors.add(c);

  void addShortcode(Shortcode shortcode) {
    // TODO check name of shortcode

    if (_shortcodes.containsKey(shortcode.name)) {
      throw new ArgumentError.value(shortcode, 'shortcode',
          'Shortcode with name ${shortcode.name} already exists!');
    }

    _shortcodes[shortcode.name] = shortcode;
  }

  void start() {
    _collectors.first.onChange
        .transform(
            mergeAll(_collectors.sublist(1).map((c) => c.onChange).toList()))
        .transform(debounce(new Duration(seconds: 1)))
        .listen((_) {
      print('Changes detected! Building .....');
      process();
    });

    process();
  }

  Future process() async {
    // TODO

    for (final c in _collectors) {
      final s = await c.collect();

      await s.map((CollectedPost p) {
        print(p.meta.section);
        print(p.meta.slugs);
        print(p.content);

        p.content = render(p.content);

        return p;
      });
    }
  }

  String render(String content) {
    final lines = LineSplitter.split(content).toList();

    final outputs = <String>[];

    int startIdx = 0;
    String scName;
    final List<String> scParam = <String>[];
    int i = 0;
    String line;

    bool exec() {
      if (scName == null) {
        if (!line.startsWith('{{<')) return false;
        if (!line.endsWith('>}}')) return false;
      } else {
        if (!line.startsWith(new RegExp(r'{{<[ \t]*\\' + scName + '[ \t]*>}}')))
          return false;
      }

      final string = lines.sublist(startIdx, i).join('\n');

      if (string.isNotEmpty) {
        if (scName == null) {
          // Render markdown
          outputs.add(markdownToHtml(string));
        } else {
	        // Call shortcode
          final sc = _shortcodes[scName];
          outputs.add(sc.transform(scParam, string));
        }
      }

      return false;
    }

    for (; i < lines.length; i++) {
      if (startIdx == null) startIdx = i;

      line = lines[i];

      if (!exec()) continue;

      scName = null;
      scParam.clear();
      startIdx = null;

      // TODO parse name

	    // TODO parse params

      if (!line.endsWith('/>}}')) {
	      // Call shortcode
	      final sc = _shortcodes[scName];
	      outputs.add(sc.transform(scParam, null));

	      scName = null;
	      scParam.clear();
	      startIdx = null;
      }
    }

    return outputs.join('\n');
  }
}
