abstract class IoException implements Exception {
  IoException(this.message);

  final String message;

  @override
  String toString() => "$runtimeType: $message";
}

class IoFileReadException extends IoException {
  IoFileReadException(super.message);
}

class IoCommandNotFoundException extends IoException {
  IoCommandNotFoundException(this.path)
    : super("IoCommand not found for file located at $path");

  final String path;
}

class IoParserNotFoundException<T> extends IoException {
  IoParserNotFoundException() : super("Parser not found for type $T");
}

class IoUnsupportedOutputException<T> extends IoException {
  IoUnsupportedOutputException() : super("Output not supported for type $T");
}

class IoInvalidFormatException extends IoException {
  IoInvalidFormatException(super.message);
}

class IoParserUnimplementedException extends IoException {
  IoParserUnimplementedException() : super("Parser not implemented");
}
