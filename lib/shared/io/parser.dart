import 'dart:async';
import 'dart:io';

/// A base class for all file parsers in the application.
///
/// [T] represents the type of object the parser will produce.
abstract class Parser<T> {
  Parser(this.file);

  /// The source file to be parsed.
  final File file;

  /// The MD5 checksum of the file content, used for caching or identification.
  String? md5Hash;

  /// Initializes the parser by reading file metadata or content.
  /// Returns `true` if initialization was successful.
  Future<bool> init();

  /// Returns the [md5Hash] or an empty string if not yet calculated.
  String get fileHash => md5Hash ?? "";

  /// Processes the file and returns the parsed object of type [T].
  /// Returns `null` if parsing fails or the file is invalid.
  FutureOr<T?> parse();
}
