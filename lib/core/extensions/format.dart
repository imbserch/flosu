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

extension ToPrintableDuration on num {
  String get toPrintableDuration {
    if (this < 1000) return "0 s";

    final seconds = this ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;

    if (hours > 0) return "${hours}h ${minutes % 60}m ${seconds % 60}s";
    if (minutes > 0) return "$minutes m ${seconds % 60} s";
    return "$seconds s";
  }
}
