part of jaguar.martini.core;

/// Receives a [Stream] of [CollectedPost]s and builds the site model from it
///
/// Composer composes the site hierarchy from the posts
class Composer {
	final Site site;

	Composer(SiteMetaData siteMeta): site = new Site(siteMeta);

	Future stream(Stream<CollectedPost> posts) async {
		await for (final CollectedPost post in posts) {
			final secName = post.meta.section;

			if (!site.sections.containsKey(secName)) {
				site.sections[secName] = new Section(site, secName);
			}

			final Section section = site.sections[secName];

			final page = new SinglePage(section, post.meta, post.content);
			section.pages.add(page);

			for (final String tagName in post.meta.tags) {
				if (!site.tags.containsKey(tagName)) {
					site.tags[tagName] = new Tag(site, tagName);
				}

				final Tag tag = site.tags[tagName];

				tag.pages.add(page);
				page.tags.add(tag);
			}

			for (final String catName in post.meta.categories) {
				if (!site.categories.containsKey(catName)) {
					site.categories[catName] = new Category(site, catName);
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