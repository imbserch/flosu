import 'package:flosu/core/enums.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flutter/painting.dart';

/// Stores the result of a single hit evaluation on a [HitObject].
///
/// Created by the [GameplayController] whenever the player presses a key
/// in the vicinity of an active object, or when an object is automatically
/// marked as a miss after its timing window expires.
class HitData {
  const HitData(
    this.timeLeft,
    this.fromCenter,
    this.difficulty,
    this.hitObject,
  );

  /// Constructs a miss entry for an object that was never hit.
  ///
  /// [timeLeft] is set to a large negative value so that [result] always
  /// resolves to [HitResult.miss].
  const HitData.fromMiss(this.hitObject, this.difficulty)
    : fromCenter = Offset.zero,
      timeLeft = -1000000;

  /// Timing error of the hit, in milliseconds.
  ///
  /// `timeLeft = hitTime - positionInMs` at the moment of input:
  /// - Positive → player hit early.
  /// - Negative → player hit late.
  /// - `-1000000` → this is a miss (constructed via [HitData.fromMiss]).
  final double timeLeft;

  /// Distance from the center of the hit object to the cursor at hit time,
  /// in playfield coordinates. [Offset.zero] for misses.
  final Offset fromCenter;

  /// The difficulty settings of the beatmap, used to evaluate the [result].
  final BeatmapDifficulty difficulty;

  /// The [HitObject] that was evaluated.
  final HitObject hitObject;

  /// Derives the scoring outcome based on the timing error and difficulty windows.
  ///
  /// Checks are ordered from tightest window to widest:
  /// - Within [BeatmapDifficulty.hit300] → [HitResult.great]
  /// - Within [BeatmapDifficulty.hit100] → [HitResult.ok]
  /// - Within [BeatmapDifficulty.hit50]  → [HitResult.meh]
  /// - Otherwise                         → [HitResult.miss]
  HitResult get result {
    final absTime = timeLeft.abs();

    if (absTime <= difficulty.hit300) return HitResult.great;
    if (absTime <= difficulty.hit100) return HitResult.ok;
    if (absTime <= difficulty.hit50) return HitResult.meh;
    return HitResult.miss;
  }
}
