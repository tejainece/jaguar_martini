part of jaguar.martini.core;

class Builder {
  final List<PostCollector> _collectors;

  final Map<String, ShortCode> _shortcodes;

  final _Renderer _renderer;

  final SiteMetaData siteMeta;

  Builder(this.siteMeta, SiteRenderer renderer, this._collectors)
      : _renderer = new _Renderer(renderer),
        _shortcodes = composeShortcodes(renderer.shortcodes) {}

  Stream<Map<String, String>> get watcher => _collectors.first.onChange
      .transform(
          mergeAll(_collectors.sublist(1).map((c) => c.onChange).toList()))
      .transform(debounce(new Duration(seconds: 1)))
      .asyncMap((_) async => await compile());

  Future<Map<String, String>> compile() async {
    final composer = new Composer(siteMeta);

    for (final c in _collectors) {
      final s = await c.collect();

      final posts = await s.map((CollectedPost p) {
        try {
          p.content = renderMarkdown(p.content);
        } on PostException catch (e) {
          print('Error whiĺe processing post ${p.meta.slugs} in section ${p.meta
                    .section}:');
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
      final List<String> html = await _renderer.sectionIndex(section);
      if (html.length > 0) {
        outputs['/${section.name}/index.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['${section.permalinkRel}/page/${i + 1}.html'] = html[i];
        }
      }

      // Generate single pages
      for (final SinglePage page in section.pages) {
        final String html = await _renderer.sectionSingle(section.name, page);
        outputs[page.permalinkRel] = html;
      }

      // Generate tag list pages for site
      for (Tag tag in section.tags) {
        final List<String> html = await _renderer.siteTag(tag);
        if (html.length > 0) {
          outputs['/${section.name}/tags/${tag.name}/index.html'] = html.first;
          for (int i = 0; i < html.length; i++) {
            outputs['/${section.name}/tags/${tag.name}/${i + 1}.html'] =
                html[i];
          }
        }
      }

      // Generate category list pages for site
      for (Category cat in section.categories) {
        final List<String> html = await _renderer.siteCategory(cat);
        if (html.length > 0) {
          outputs['/${section.name}/categories/${cat.name}/index.html'] =
              html.first;
          for (int i = 0; i < html.length; i++) {
            outputs['/${section.name}/categories/${cat.name}/${i + 1}.html'] =
                html[i];
          }
        }
      }
    }

    // Generate tag list pages for site
    for (String tagName in site.tags.keys) {
      final Tag tag = site.tags[tagName];
      final List<String> html = await _renderer.siteTag(tag);
      if (html.length > 0) {
        outputs['/tags/${tagName}.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/tags/${tagName}/${i + 1}.html'] = html[i];
        }
      }
    }

    // Generate category list pages for site
    for (String catName in site.categories.keys) {
      final Category cat = site.categories[catName];
      final List<String> html = await _renderer.siteCategory(cat);
      if (html.length > 0) {
        outputs['/categories/${catName}.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/categories/${catName}/${i + 1}.html'] = html[i];
        }
      }
    }

    // Render site home/index page
    {
      final List<String> html = await _renderer.siteIndex(site);
      if (html.length > 0) {
        outputs['/index.html'] = html.first;
        for (int i = 0; i < html.length; i++) {
          outputs['/${i + 1}.html'] = html[i];
        }
      }
    }

    return outputs;
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
