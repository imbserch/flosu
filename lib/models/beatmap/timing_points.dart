part of "beatmap.dart";

sealed class TimingPoint {
  const TimingPoint({required this.time, required this.meter});

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
  final int time;
  final int meter;
}

class UTimingPoint extends TimingPoint {
  const UTimingPoint({
    required super.time,
    required this.beatLength,
    required super.meter,
  });
  final double beatLength;
}

class ITimingPoint extends TimingPoint {
  const ITimingPoint({
    required super.time,
    required double mult,
    required super.meter,
  }) : beatMultiplier = -100.0 / mult;
  final double beatMultiplier;
}
