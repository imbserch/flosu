import 'package:flosu/core/enums.dart';

class Log {
  const Log(this.tag, this.message, this.level, this.timestamp);

  final String tag;
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  @override
  String toString() {
    final levelStr = <LogLevel>[.debug, .info].contains(level)
        ? ''
        : '${level.name.toUpperCase()}: ';

    return '[$tag] $levelStr$message';
  }
}
