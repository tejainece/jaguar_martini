part of jaguar.martini.core;

class Processor {
  final List<PostCollector> _collectors = [];

  final _shortcodes = <String, Shortcode>{};

  final Writer _writer;

  Processor(SectionWriter fallback,
      {Map<String, SectionWriter> sectionWriters: const {},
      List<Shortcode> shortcodes: const []})
      : _writer = new Writer(fallback, sections: sectionWriters) {
    addShortcodes(shortcodes);
  }

  bool _working = false;

  /// Adds a post collector
  void add(PostCollector c) => _collectors.add(c);

  void addShortcodes(List<Shortcode> shortcodes) {
    for (final sc in shortcodes) addShortcode(sc);
  }

  /// Add shortcode processor to process shortcodes in content Markdown
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
    while (_working) await new Future.delayed(new Duration(milliseconds: 500));
    _working = true;

    final composer = new Composer();

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

    for(final Section section in site.sections.values) {
      final SectionWriter w = _writer.sections[section.name]??_writer.fallback;

      // TODO Generate section list pages

      // Generate single pages
      for(final SinglePage page in section.pages) {
        final String html = await w.single(page);

        print(html);
        // TODO write to cache or file system
      }
    }

    // TODO generate tag list pages

    // TODO generate category list pages

    // TODO generate home page

    // TODO

    _working = false; // TODO must also be freed when there is an exception
  }

  String renderMarkdown(String content) {
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

class Writer {
  /// Fallback section renderer
  ///
  /// Used when [sections] does not have an entry for the rendered section
  final SectionWriter fallback;

  final Map<String, SectionWriter> sections;

  Writer(this.fallback, {this.sections: const {}});
}

abstract class SectionWriter {
  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page);

  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<String> list(ListPage page);
}

/// Receives a [Stream] of [CollectedPost]s and builds the site model from it
class Composer {
  final site = new Site();

  Future stream(Stream<CollectedPost> posts) async {
    await for (final CollectedPost post in posts) {
      final secName = post.meta.section;

      if (!site.sections.containsKey(secName)) {
        site.sections[secName] = new Section(secName);
      }

      final Section section = site.sections[secName];

      final page =
          new SinglePage(section, post.meta, post.content, '' /* TODO */);
      section.pages.add(page);

      for(final String tagName in post.meta.tags) {
        if(!site.tags.containsKey(tagName)) {
          site.tags[tagName] = new Tag(tagName);
        }

        final Tag tag = site.tags[tagName];

        tag.pages.add(page);
        page.tags.add(tag);
      }

      for(final String catName in post.meta.categories) {
        if(!site.tags.containsKey(catName)) {
          site.categories[catName] = new Category(catName);
        }

        final Category cat = site.categories[catName];

        cat.pages.add(page);
        page.categories.add(cat);
      }

      // TODO
    }

    // TODO sort pages in site

    // TODO sort pages in section

    // TODO sort pages in tags

    // TODO sort pages in categories
  }
}
