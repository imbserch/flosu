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
