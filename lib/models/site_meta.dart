part of jaguar.martini.models;

class SiteMetaData {
	final String title;

	final String baseURL;

	final List<String> authors;

	final String copyright;

	final Map<String, dynamic> params;

	const SiteMetaData(
			{@required this.title,
				@required this.baseURL,
				this.authors: const <String>[],
				this.copyright,
				this.params: const <String, dynamic>{}});

	factory SiteMetaData.yaml(Map<String, dynamic> yaml) {
		final String title = yaml['title'];
		String baseURL = yaml['baseURL'];
		List<String> authors = yaml['authors'] ?? <String>[];
		String copyright = yaml['copyright'];
		Map<String, dynamic> params = yaml['params'] ?? <String, dynamic>{};

		// TODO validate

		return new SiteMetaData(
				title: title,
				baseURL: baseURL,
				authors: authors,
				copyright: copyright,
				params: params);
	}
}