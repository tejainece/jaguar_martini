part of jaguar.martini.core;

class Processor {
  final List<PostCollector> _collectors = [];

  final _shortcodes = <String, ShortCode>{};

  final Writer _writer;

  final cache = new InMemoryCache<Response>(null);

  final SiteMetaData siteMeta;

  Processor(this.siteMeta, SectionWriter fallback,
      {Map<String, SectionWriter> sectionWriters: const {},
      List<ShortCode> shortcodes: const []})
      : _writer = new Writer(fallback, sections: sectionWriters) {
    addShortcodes(shortcodes);
  }

  bool _working = false;

  /// Adds a post collector
  void add(PostCollector c) => _collectors.add(c);

  void addShortcodes(List<ShortCode> shortcodes) {
    for (final sc in shortcodes) addShortcode(sc);
  }

  /// Add shortcode processor to process shortcodes in content Markdown
  void addShortcode(ShortCode shortcode) {
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
    while (_working) await new Future.delayed(new Duration(milliseconds: 500));
    _working = true;

    final composer = new Composer(siteMeta);

    for (final c in _collectors) {
      final s = await c.collect();

      final posts = await s.map((CollectedPost p) {
        print(p.meta.section);
        print(p.meta.slugs);
        print(p.content);

        p.content = renderMarkdown(p.content);

        return p;
      });

      await composer.stream(posts);
    }

    final Site site = composer.site;

    /// A map of URL to output
    final outputs = <String, String>{};

    for (final Section section in site.sections.values) {
      final SectionWriter w =
          _writer.sections[section.name] ?? _writer.fallback;

      // Generate section list pages
      final List<String> html = await _writer.fallback.list(section);
      if (html.length > 0) {
        outputs['/${section.name}'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/${section.name}/page/${i+1}'] = html[i];
        }
      }

      // Generate single pages
      for (final SinglePage page in section.pages) {
        final String html = await w.single(page);
        outputs[page.meta.url] = html;
      }
    }

    // Generate tag list pages for site
    for (String tagName in site.tags.keys) {
      final Tag tag = site.tags[tagName];
      final List<String> html = await _writer.fallback.list(tag);
      if (html.length > 0) {
        outputs['/tags/${tagName}'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/tags/${tagName}/page/${i+1}'] = html[i];
        }
      }
    }

    // Generate category list pages for site
    for (String catName in site.categories.keys) {
      final Category cat = site.categories[catName];
      final List<String> html = await _writer.fallback.list(cat);
      if (html.length > 0) {
        outputs['/categories/${catName}'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/categories/${catName}/page/${i+1}'] = html[i];
        }
      }
    }

    // TODO generate home page

    cache.clear();

    for (final String path in outputs.keys) {
      cache.upsert(
          path,
          new Response(UTF8.encode(outputs[path]))
            ..headers.charset = 'utf8'
            ..headers.mimeType = 'text/html');
    }

    _working = false; // TODO must also be freed when there is an exception
  }

  String renderMarkdown(String content) {
    final lines = LineSplitter.split(content).toList();

    final outputs = <String>[];

    int startIdx = 0;
    ShortCodeCall scc;
    int i = 0;

    for (; i < lines.length; i++) {
      if (startIdx == null) startIdx = i;

      final String line = lines[i];

      if (scc == null) {
        if (!ShortCode.isTag(line)) continue;

        final string = lines.sublist(startIdx, i).join('\n');

        if (string.isNotEmpty) {
          // Render markdown
          outputs.add(markdownToHtml(string));
        }
      } else {
        // TODO Should we throw on wrong use here?
        if (!ShortCode.isEndTagNamed(line, scc.name)) continue;

        final string = lines.sublist(startIdx, i).join('\n');

        // Call shortcode
        final sc = _shortcodes[scc.name];
        outputs.add(sc.transform(scc.values, string));

        continue;
      }

      scc = ShortCodeCall.parse(line);

      if (ShortCode.isSingleLineTag(line)) {
        // Call shortcode
        final sc = _shortcodes[scc.name];
        outputs.add(sc.transform(scc.values, null));

        scc = null;
        startIdx = null;
      }
    }

    return outputs.join('\n');
  }
}
