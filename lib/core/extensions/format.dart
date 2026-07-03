import 'package:flosu/logic/services/logger.dart';
import 'package:flutter/foundation.dart';

/// Utility extension for quick logging and debugging of any object.
extension PrintExtension<T> on T {
  /// Logs the object to the console using [print] and returns it.
  ///
  /// Only produces output in [kDebugMode], making it safe to leave call sites
  /// in production code without performance impact.
  ///
  /// If a [logger] is provided, it will be used to log the message instead of
  /// [print].
  T log([ScopedLogger? logger]) {
    if (logger != null) {
      logger.log(toString(), LogLevel.info);
      return this;
    }

    if (kDebugMode) debugPrint(toString());
    return this;
  }

  /// Prints a specific property of the object and returns the original value.
  ///
  /// Useful for logging inside method chains without breaking them.
  T logProperty<U extends Object?>(U Function(T) prop, [ScopedLogger? logger]) {
    final value = prop(this);

    if (value == null) return this;

    if (logger != null) {
      logger.log(value.toString(), LogLevel.info);
      return this;
    }

    if (kDebugMode) debugPrint(value.toString());
    return this;
  }
}

/// Extension to format a [Duration] as a human-readable HH:MM:SS string.
extension DurationExtension on Duration {
  String get formatted => "$this".split(".").first;
}

/// Extension to format a [DateTime] as a HH:MM:SS time string.
extension DateTimeExtension on DateTime {
  String get formatted => "$this".split(" ").last.substring(0).split(".").first;
}

/// Extension to format numbers with exactly two decimal places.
extension DoubleExtensions on num {
  String get format => toStringAsFixed(2);
}
