part of "beatmap.dart";

enum TimingType { normal, inherited }

sealed class Timing {
  const Timing(
    this.time,
    this.beatLength,
    this.meter,
    this.volume,
    this.isKiai,
  );

  final double beatLength;
  final double time;
  final int meter;
  final double volume;

  final bool isKiai;

  bool get isInherited => this is InheritedTiming;
}

class NormalTiming extends Timing {
  const NormalTiming(
    super.time,
    super.beatLength,
    super.meter,
    super.volume,
    super.isKiai,
  );
}

class InheritedTiming extends Timing {
  const InheritedTiming(
    super.time,
    super.beatLength,
    super.meter,
    super.volume,
    super.isKiai,
  );
}
