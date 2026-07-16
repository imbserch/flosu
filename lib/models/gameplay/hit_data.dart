import 'package:flosu/core/enums.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';
import 'package:flutter/painting.dart';

/// Stores the result of a single hit evaluation on a [HitObject].
class HitData {
  const HitData(
    this.timeLeft,
    this.fromCenter,
    this.difficulty,
    this.hitObject,
  );

  /// Constructs a miss entry for an object that was never hit.
  const HitData.fromMiss(this.hitObject, this.difficulty)
    : fromCenter = Offset.zero,
      timeLeft = -1000000;

  /// Timing error of the hit, in milliseconds.
  final double timeLeft;

  /// Distance from the center of the hit object to the cursor at hit time,
  /// in playfield coordinates. [Offset.zero] for misses.
  final Offset fromCenter;

  /// The metadata of the beatmap containing difficulty settings.
  final BeatmapDifficultyMetadata difficulty;

  /// The [HitObject] that was evaluated.
  final HitObject hitObject;

  /// Derives the scoring outcome based on the timing error and difficulty windows.
  HitResult get result {
    final absTime = timeLeft.abs();

    if (absTime <= difficulty.hit300) return HitResult.great;
    if (absTime <= difficulty.hit100) return HitResult.ok;
    if (absTime <= difficulty.hit50) return HitResult.meh;
    return HitResult.miss;
  }
}
