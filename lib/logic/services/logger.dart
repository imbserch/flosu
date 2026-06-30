import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flosu/core/enums.dart';
import 'package:flutter/foundation.dart';

export 'package:flosu/core/enums.dart' show LogLevel;

// ignore: constant_identifier_names
const MAX_LOG_TIME = 20;

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

class Log {
  const Log(this.tag, this.message, this.level, this.timestamp);

  final String tag;
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  @override
  String toString() {
    final timeStr = timestamp
        .toLocal()
        .toString()
        .split(' ')
        .last
        .substring(0, 8);

    final levelStr = level.name.toUpperCase();

    return "[$levelStr] [$timeStr] [$tag] -> $message";
  }
}

class Logger {
  Logger._() {
    _pruneLogsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _pruneLogs(),
    );
  }

  static final Logger _instance = Logger._();
  static Logger get instance => _instance;

  void dispose() {
    _pruneLogsTimer.cancel();
    _scopedLoggers.clear();
    logs.dispose();
  }

  final ValueNotifier<List<Log>> logs = ValueNotifier([]);
  late final Timer _pruneLogsTimer;

  final Map<String, ScopedLogger> _scopedLoggers = {};

  static ScopedLogger requestLogger(String serviceName) =>
      _instance._requestLogger(serviceName);

  ScopedLogger _requestLogger(String serviceName) {
    if (_scopedLoggers.containsKey(serviceName)) {
      return _scopedLoggers[serviceName]!;
    }
    final logger = ScopedLogger._(serviceName);
    _scopedLoggers[serviceName] = logger;
    return logger;
  }

  /// Prunes logs that are older than 5 seconds
  void _pruneLogs() {
    final currentLogs = logs.value;
    if (currentLogs.isEmpty) return;

    final now = DateTime.now();

    final lastDebugLog = currentLogs.lastWhereOrNull((log) {
      final diffSeconds = now.difference(log.timestamp).inSeconds;
      final isDebugLog = log.level == LogLevel.debug;

      return isDebugLog && diffSeconds < MAX_LOG_TIME;
    });

    logs.value = [
      ?lastDebugLog,
      for (final log in currentLogs)
        if (log.level != LogLevel.debug)
          if (now.difference(log.timestamp).inSeconds < MAX_LOG_TIME) log,
    ];
  }

  void releaseLogger(ScopedLogger logger) {
    _scopedLoggers.remove(logger.serviceName);
  }

  void _addLog(Log log) {
    if (kDebugMode) print(log.toString());

    // Don't add debug logs in release mode
    if (!kDebugMode && log.level == LogLevel.debug) return;

    logs.value = [...logs.value, log];
    _pruneLogs();
  }
}
