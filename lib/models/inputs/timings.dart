// Represents the metrics/timings of immediate and delayed hardware events
class InputTimings {
  InputTimings({
    required this.delayedEventsDuration,
    required this.immediateEventsDuration,
  });

  final List<Duration> delayedEventsDuration;
  final List<Duration> immediateEventsDuration;
}
