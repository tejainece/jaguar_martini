import 'dart:async';
import 'package:stencil/stencil.dart';
import 'package:jaguar_martini/jaguar_martini.dart';
import 'package:intl/intl.dart';

class HeadComp extends Component {
  final AnyPage page;

  HeadComp(this.page);

  Site get site => page.site;

  String get title {
    if (page is SinglePage) {
      return (page as SinglePage).meta.title + ': ' + site.meta.title;
    } else if (page is Tag) {
      return (page as Tag).name + ': ' + site.meta.title;
    } else if (page is Category) {
      return (page as Category).name + ': ' + site.meta.title;
    } else if (page is Section) {
      return (page as Section).name + ': ' + site.meta.title;
    } else if (page is Site) {
      return (page as Site).meta.title;
    }
    throw new UnsupportedError('Unsupported list page!');
  }

  String render() {
    return '''
<head>
    <title>$title</title>
    <meta property='og:title' content="$title">
    <meta property="og:type" content="${page is Site? 'website': 'article'}">
    ${when(page is SinglePage, () => '<meta name="description" content="${(page as SinglePage).meta.description}">')}
    <meta property="og:url" content="${page.permalink}">
    <!-- TODO meta og:image -->

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">

    <meta name="generator" content="Martini 0.1.0" />

    <!-- Fonts -->
    <link rel='stylesheet' href='//fonts.googleapis.com/css?family=Open+Sans|Marcellus+SC'>
    <link href="https://fonts.googleapis.com/css?family=Miriam+Libre:400,700|Source+Sans+Pro:200,400,700,600,400italic,700italic" rel="stylesheet" type="text/css">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <!-- Font awesome -->
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">

    <!-- My stylesheets -->
    <link rel="stylesheet" href="${site.meta.baseURL}/static/css/prettify_own.css">
    <link rel="stylesheet" href="${site.meta.baseURL}/static/css/styles.css">
    <link rel="stylesheet" href="${site.meta.baseURL}/static/css/custom.css">
    <!-- My RSS -->
    <link rel="alternate" type="application/rss+xml" title="RSS" href="${site.meta.baseURL}/index.xml">

    <!--Google prettify-->
    <script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js?lang=dart&lang=go&lang=css&lang=swift&lang=vhdl&lang=yaml"></script>
</head>
    ''';
  }
}

class PaginationInfo {
  final int number;

  final int itemsPerPage;

  final itemsInThisPage;

  PaginationInfo(this.itemsPerPage, this.number, this.itemsInThisPage);

  int get start => (number - 1) * itemsPerPage;

  int get end => start + itemsInThisPage;
}

class ArticleListPageComp extends Component {
  final ListPage page;

  final PaginationInfo paginationInfo;

  ArticleListPageComp(this.page, this.paginationInfo);

  Site get site => page.site;

  String get heading {
    if (page is Tag) {
      return (page as Tag).name;
    } else if (page is Category) {
      return (page as Category).name;
    } else if (page is Section) {
      return (page as Section).name;
    }
    throw new UnsupportedError('Unsupported list page!');
  }

  @override
  String render() {
    return '''
<html>
  ${comp(new HeadComp(page))}

  <body>
    <header class="site">
      <div class="title"><a href="${site.meta.baseURL}">${site.meta.title}</a></div>
    </header>

    <div class="container site">

    <div class="list">
      <header class="list-title"><h1>$heading</h1></header>

      <div class="row">
        <div class="col-sm-9">
          <div class="articles">
            ${range(paginationInfo.start, paginationInfo.end,
								(i) => new ArticleInListComp(page.pages[i]).render())}
          </div>

          <!-- TODO {{ partial "pagination.html" . }} -->
        </div>
        <div class="col-sm-3 sidebar">
          ${comp(new SidebarComp(page))}
        </div>
      </div>
    </div>
    <!-- TODO {{ partial "default_foot.html" . }} -->
  </body>
</html>
    ''';
  }
}

final DateFormat dateFormatter = new DateFormat('EEE, MMM d, yyyy');

class ArticleInListComp extends Component {
  final SinglePage page;

  ArticleInListComp(this.page);

  @override
  String render() {
    return '''
<article class="single" itemscope="itemscope" itemtype="http://schema.org/Article">
  <header class="article-header">
    <time itemprop="datePublished" pubdate="pubdate"
                  datetime="${page.meta.date.toString()}">
      ${dateFormatter.format(page.meta.date)}
    </time>
    <h1 class="article-title">
      <a href="${page.permalink}">${page.meta.title}</a>
    </h1>
  </header>

  <div class="article-body" itemprop="articleBody">${page.content}</div>

  <aside>
    <div class="section">
      ${forEach(page.tags, (Tag t) => '<a href="${t.permalink}" class="tag">${t.name}</a>')}
    </div>
  </aside>
</article>
    ''';
  }
}

class SidebarComp extends Component {
  final AnyPage page;

  SidebarComp(this.page);

  @override
  String render() {
    return '''
<aside class="site">
	<div class="section">
	  <header><div class="title">LatestPosts</div></header>
	  <div class="content">
	    ${forEach(page.site.pages.take(10), (SinglePage p) => '''
	    <div class="sm">
		    <article class="li">
				  <a href="${p.permalink}" class="clearfix">
				    <div class="detail">
				      <time>${dateFormatter.format(p.meta.date)}</time>
				      <h2 class="title">${p.meta.title}</h2>
				    </div>
				  </a>
				</article>
	    </div>
	    ''')}
	  </div>
	</div>

	<div class="section">
	  <header><div class="title">Categories</div></header>
	  <div class="content">
	    ${forEach(page.site.categories.values, (Category c) => '''
	    <a href="${c.permalink}">${c.name}</a>
	    ''')}
	  </div>
	</div>

	<div class="section taxonomies">
	  <header><div class="title">Tags</div></header>
	  <div class="content">
	    ${forEach(page.site.tags.values.take(10), (Tag t) => '''
	    <a href="${t.permalink}">${t.name}</a>
	    ''')}
	  </div>
	</div>
</aside>
		''';
  }
}

class FallbackWriter implements SectionWriter {
  /// Renders single pages of the section
  FutureOr<String> single(SinglePage page) {
    return '''
<html>
  ${new HeadComp(page).render()}
  <body>
    ${page.content}
  </body>
</html>
    ''';
  }

  /// Renders list pages of the section
  ///
  /// List pages include
  FutureOr<List<String>> list(ListPage page) {
    final int articlesPerPage = 10;
    final ret = <String>[];
    for (int i = 0; i < page.pages.length; i += articlesPerPage) {
      final int pageNum = (i ~/ articlesPerPage) + 1;
      int itemsInThisPage = articlesPerPage;
      if ((i + itemsInThisPage) > page.pages.length) {
        itemsInThisPage = page.pages.length % articlesPerPage;
      }
      final paginationInfo =
          new PaginationInfo(articlesPerPage, pageNum, itemsInThisPage);
      ret.add(new ArticleListPageComp(page, paginationInfo).render());
    }
    return ret;
  }
}
