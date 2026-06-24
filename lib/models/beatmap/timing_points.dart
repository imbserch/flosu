part of "beatmap.dart";

/// Base class for entries in the `[TimingPoints]` section of a `.osu` file.
///
/// Each timing point starts at a given [time] and defines a beat structure
/// that governs BPM, slider velocity, and hitsound settings until the next
/// timing point begins.
sealed class TimingPoint {
  const TimingPoint({required this.time, required this.meter});

  /// Parses a single timing-point row from the `.osu` file format.
  ///
  /// The `isUninherited` flag (column 7) determines whether this is a
  /// [UTimingPoint] (absolute BPM) or an [ITimingPoint] (relative SV).
  factory TimingPoint.fromList(List<String> row) {
    final int time = int.tryParse(row[0]) ?? 0;
    final double value = double.parse(row[1]);
    final int meter = int.parse(row[2]);
    final bool isUninherited = row[6] == '1';

    if (isUninherited) {
      return UTimingPoint(
        time: time,
        beatLength: row[1] == "NaN" ? 6 : value,
        meter: meter,
      );
    } else {
      return ITimingPoint(
        time: time,
        mult: row[1] == "NaN" ? -100 : value,
        meter: meter,
      );
    }
  }

  /// Timestamp (in ms) at which this timing point takes effect.
  final int time;

  /// Number of beats per measure (time signature numerator).
  final int meter;
}

/// An uninherited (red) timing point that defines an absolute BPM value.
///
/// These are the "anchor" timing points that set the fundamental beat length.
/// Slider velocity at this point is always 1.0×.
class UTimingPoint extends TimingPoint {
  const UTimingPoint({
    required super.time,
    required this.beatLength,
    required super.meter,
  });

  /// Duration of one beat in milliseconds.
  ///
  /// BPM = 60000 / beatLength.
  final double beatLength;
}

/// An inherited (green) timing point that adjusts slider velocity relative to
/// the preceding [UTimingPoint].
///
/// Does not change BPM — only the slider velocity multiplier.
class ITimingPoint extends TimingPoint {
  const ITimingPoint({
    required super.time,
    required double mult,
    required super.meter,
  }) : beatMultiplier = -100.0 / mult;

  /// The slider velocity multiplier derived from the raw `mult` value.
  ///
  /// `beatMultiplier = -100 / mult` where [mult] is a negative value like
  /// `-50` (2× speed) or `-200` (0.5× speed).
  final double beatMultiplier;
}
