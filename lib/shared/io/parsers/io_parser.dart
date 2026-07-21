import 'package:flosu/shared/io/io_exceptions.dart';

abstract class IoParser<T> {
  IoParser(this.path);

  final String path;

  Future<T> parse() => throw IoParserUnimplementedException();
}
