import 'package:jaguar_martini/core/core.dart';

class Page {
	/// Metadata of the page picked from front-matter
	final PostMeta meta;

	/// The processed content itself
	final String content;

	/// The approximate number of words in the content
	// TODO int fuzzyWordCount;

	final bool isHome;

	final Page next;

	final Page prev;

	final Page nextInSection;

	final Page prevInSection;

	// TODO Page nextInSeries;

	// TODO Page nextInSeries;

	// TODO pages

	// TODO permalink

	// TODO plain

	// TODO plain words

	// TODO reading time

	/// The section this page belongs to
	final Section section;

	// TODO summary

	// TODO table of contents

	/// The URL for the page relative to the web root. Note that a url set directly
	/// in front matter overrides the default relative URL for the rendered page.
	final String url;

	// TODO int wordCount
}

class Section {
	// TODO
}