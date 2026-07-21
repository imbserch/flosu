part of "logger.dart";

class ScopedLogger {
  ScopedLogger._(this.serviceName);
  bool _isDisposed = false;

  final String serviceName;

  void log(String message, LogLevel level) {
    assert(!_isDisposed, "ScopedLogger was disposed: $serviceName");
    if (_isDisposed) return;

    // Delegar la inserción al Logger central
    Logger.instance._addLog(Log(serviceName, message, level, DateTime.now()));
  }

  void debug(String message) => log(message, LogLevel.debug);
  void info(String message) => log(message, LogLevel.info);
  void warn(String message) => log(message, LogLevel.warning);
  void error(String message) => log(message, LogLevel.error);

  void dispose() {
    _isDisposed = true;
    Logger.instance.releaseLogger(this);
  }
}
