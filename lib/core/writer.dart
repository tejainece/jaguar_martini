part of jaguar.martini.core;

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
	FutureOr<List<String>> list(ListPage page);
}