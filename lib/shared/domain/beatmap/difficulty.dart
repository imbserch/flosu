part of 'beatmap.dart';

/// Modifiable properties of a difficulty settings.
@embedded
class Difficulty {
  double approachRate = 5.0;
  double circleSize = 5.0;
  double hpDrain = 5.0;
  double overallDifficulty = 5.0;

  double sliderMultiplier = 1.0;
  double sliderTickRate = 1.0;

  double stackLeniency = 0.7;

  @ignore
  double get radius => (54.4 - (4.48 * circleSize)) * 1.00041;

  /// Time to fade in
  @ignore
  double get preempt => approachRate <= 5
      ? 1200 + 120 * (5 - approachRate)
      : 1200 - 150 * (approachRate - 5);

  /// Half width of 300 window
  @ignore
  double get hit300 => 80 - 6 * overallDifficulty;

  /// Half width of 100 window
  @ignore
  double get hit100 => 140 - 8 * overallDifficulty;

  /// Half width of 50 window
  @ignore
  double get hit50 => 200 - 10 * overallDifficulty;

  /// The stack threshold time.
  @ignore
  double get stackThreshold => preempt * stackLeniency;

  @ignore
  double get tickDistance =>
      sliderTickRate > 0 ? (100 * sliderMultiplier) / sliderTickRate : 0.0;
}
