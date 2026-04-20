import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';

class HitData {
  const HitData(
    this.timeLeft,
    this.fromCenter,
    this.difficulty,
    this.hitObject,
    this.widgetObject,
  );

  const HitData.fromMiss(this.hitObject, this.difficulty)
    : fromCenter = .zero,
      timeLeft = -1000000,
      widgetObject = const SizedBox.shrink();

  final double timeLeft;
  final Offset fromCenter;
  final BeatmapDifficulty difficulty;
  final HitObject hitObject;
  final Widget widgetObject;

  HitResult get result {
    final isGreat = difficulty.hit300.round() > timeLeft.abs();
    final isOk = difficulty.hit100.round() > timeLeft.abs();
    final isMeh = difficulty.hit50.round() > timeLeft.abs();

    if (isGreat) return .great;
    if (isOk) return .ok;
    if (isMeh) return .meh;
    return .miss;
  }
}
