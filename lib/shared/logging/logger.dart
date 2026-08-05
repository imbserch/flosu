import 'dart:async';
import 'package:flosu/core/constants.dart';
import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/shared/logging/log.dart';
import 'package:flutter/foundation.dart';

part 'scoped_logger.dart';

class Logger {
  Logger._() {
    _pruneLogsTimer = Timer.periodic(
      const Duration(seconds: 20),
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

    // Ensure log update is async
    Future.microtask(
      () => logs.value = [
        for (final log in currentLogs)
          if ((GameLoop.time - log.timestamp) < MAX_LOG_TIME) log,
      ],
    );
  }

  void releaseLogger(ScopedLogger logger) {
    _scopedLoggers.remove(logger.serviceName);
  }

  void _addLog(Log log) async {
    if (!kReleaseMode) {
      final style = switch (log.level) {
        LogLevel.success => "\x1B[32m",
        LogLevel.debug => "\x1B[34m",
        LogLevel.info => "\x1B[90m",
        LogLevel.warning => "\x1B[93m",
        LogLevel.error => "\x1B[91m",
      };

      debugPrint("$style$log\x1B[0m");
    }

    // Don't add debug logs in release mode
    if (kReleaseMode && log.level == LogLevel.debug) return;

    // Ensure log update is async
    await null;
    logs.value = [
      for (final l in logs.value)
        if (l.level != log.level) l,
      log,
    ];
    _pruneLogs();
  }
}
