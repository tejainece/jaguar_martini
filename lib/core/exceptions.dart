part of jaguar.martini.core;

abstract class PostException {
  String get message;

  const PostException();
}

abstract class LinedException {
  int get lineNum;
}

class ShortcodeNotFound implements PostException, LinedException {
  final String shortcodeName;

  final int lineNum;

  const ShortcodeNotFound(this.shortcodeName, this.lineNum);

  String get message => 'Shortcode $shortcodeName not found!';
}

class ShortcodeInsideShortcode implements PostException, LinedException {
  final int lineNum;

  const ShortcodeInsideShortcode(this.lineNum);

  String get message => 'A shortcode is not allowed inside another shortcode!';
}

class UnterminatedShortcode implements PostException, LinedException {
  final String shortcodeName;

  final int lineNum;

  const UnterminatedShortcode(this.shortcodeName, this.lineNum);

  String get message => 'Shortcode $shortcodeName is not terminated!';
}
