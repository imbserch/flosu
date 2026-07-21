import 'package:flosu/core/enums.dart';
import 'package:flosu/shared/logging/logger.dart';

mixin Logging {
  ScopedLogger? _logger;

  void requestLogger() {
    if (_logger != null) return;

    // Replace everything except letters and numbers
    final tag = runtimeType.toString().replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

    _logger = Logger.requestLogger(tag);
  }

  void removeLogger() => _logger?.dispose();

  void log(String message, {LogLevel level = .debug}) =>
      _logger?.log(message, level);
}
