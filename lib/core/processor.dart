part of jaguar.martini.core;

class Processor {
  final List<PostCollector> _collectors = [];

  final _shortcodes = <String, ShortCode>{};

  final Writer writer;

  final cache = new InMemoryCache<Response>(null);

  final SiteMetaData siteMeta;

  Processor(this.siteMeta, SectionWriter fallback,
      {SiteWriter siteWriter,
      Map<String, SectionWriter> sectionWriters: const {},
      List<ShortCode> shortcodes: const []})
      : writer =
            new Writer(fallback, site: siteWriter, sections: sectionWriters) {
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
        try {
          p.content = renderMarkdown(p.content);
        } on PostException catch (e) {
          print(
              'Error whiĺe processing post ${p.meta.slugs} in section ${p.meta.section}:');
          if (e is LinedException) {
            print('In line ${(e as LinedException).lineNum}');
          }
          print(e.message);
        }
        return p;
      }).where((p) => p != null);

      await composer.stream(posts);
    }

    final Site site = composer.site;

    /// A map of URL to output
    final outputs = <String, String>{};

    // Render section
    for (final Section section in site.sections.values) {
      print('Rendering section: ${section.name} ...');

      // Generate section list pages
      final List<String> html = await writer.renderSectionIndex(section);
      if (html.length > 0) {
        outputs['/${section.name}'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['${section.permalinkRel}/page/${i+1}.html'] = html[i];
        }
      }

      // Generate single pages
      for (final SinglePage page in section.pages) {
        final String html =
            await writer.renderSectionSingle(section.name, page);
        outputs[page.permalinkRel] = html;
      }

      // Generate tag list pages for site
      for (Tag tag in section.tags) {
        final List<String> html = await writer.renderSiteTag(tag);
        if (html.length > 0) {
          outputs['/tags/${tag.name}.html'] = html.first;
          for (int i = 0; i < html.length; i++) {
            outputs['/tags/${tag.name}/${i+1}.html'] = html[i];
          }
        }
      }

      // Generate category list pages for site
      for (Category cat in section.categories) {
        final List<String> html = await writer.renderSiteCategory(cat);
        if (html.length > 0) {
          outputs['/categories/${cat.name}.html'] = html.first;
          for (int i = 0; i < html.length; i++) {
            outputs['/categories/${cat.name}/${i+1}.html'] = html[i];
          }
        }
      }
    }

    // Generate tag list pages for site
    for (String tagName in site.tags.keys) {
      final Tag tag = site.tags[tagName];
      final List<String> html = await writer.renderSiteTag(tag);
      if (html.length > 0) {
        outputs['/tags/${tagName}.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/tags/${tagName}/${i+1}.html'] = html[i];
        }
      }
    }

    // Generate category list pages for site
    for (String catName in site.categories.keys) {
      final Category cat = site.categories[catName];
      final List<String> html = await writer.renderSiteCategory(cat);
      if (html.length > 0) {
        outputs['/categories/${catName}.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/categories/${catName}/${i+1}.html'] = html[i];
        }
      }
    }

    // Render site home/index page
    {
      final List<String> html = await writer.renderSiteIndex(site);
      if (html.length > 0) {
        outputs['/index.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/index/${i + 1}.html'] = html[i];
        }
      }
    }

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
    int sccLineNum;
    int i = 0;

    for (; i < lines.length; i++) {
      if (startIdx == null) startIdx = i;

      final String line = lines[i];

      if (scc == null) {
        if (!ShortCodeParser.isTag(line)) continue;

        final string = lines.sublist(startIdx, i).join('\n');

        if (string.isNotEmpty) {
          // Render markdown
          outputs.add(markdownToHtml(string));
        }
      } else {
        if (!ShortCodeParser.isEndTagNamed(line, scc.name)) {
          if (ShortCodeParser.isTag(line))
            throw new ShortcodeInsideShortcode(i);
          continue;
        }

        final string = lines.sublist(startIdx, i).join('\n');

        // Call shortcode
        final sc = _shortcodes[scc.name];
        outputs.add(sc.transform(scc.values, string));

        scc = null;
        startIdx = null;
        sccLineNum = null;

        continue;
      }

      scc = ShortCodeParser.parse(line);

      if (ShortCodeParser.isSingleLineTag(line)) {
        // Call shortcode
        final sc = _shortcodes[scc.name];

        if (sc == null) {
          throw new ShortcodeNotFound(scc.name, i);
        }

        outputs.add(sc.transform(scc.values, null));

        scc = null;
        startIdx = null;
        sccLineNum = null;
      }
    }

    if (scc != null) {
      throw new UnterminatedShortcode(scc.name, sccLineNum);
    }

    if (startIdx != null) {
      final string = lines.sublist(startIdx, i).join('\n');
      if (string.isNotEmpty) {
        // Render markdown
        outputs.add(markdownToHtml(string));
      }
    }

    return outputs.join('\n');
  }
}
