import 'package:jaguar_martini/jaguar_martini.dart';

class GistShortCode implements ShortCode {
  final String name = 'gist';

  String transform(Map<String, String> params, String content) {
    return 'Gist with id ${params['id']}';
  }

  const GistShortCode();
}
