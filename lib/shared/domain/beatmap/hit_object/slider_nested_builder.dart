import 'dart:math';

import 'package:flosu/core/constants.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';

import 'hit_object.dart';

extension SliderNestedBuilder on Slider {
  void generateNestedObjects(Beatmap beatmap) {
    // Always generate nested objects, e.g. if timing or debug slider implementation changes.
    clearNestedHitObjects();

    final normalTiming = beatmap.timings.whereType<NormalTiming>().lastWhere(
      (t) => t.time <= time,
      orElse: () =>
          beatmap.timings.whereType<NormalTiming>().firstOrNull ??
          const NormalTiming(-100000, 1000, 4, 100, false),
    );

    final double tickRate = beatmap.difficulty.sliderTickRate;
    final double tickInterval = tickRate > 0
        ? normalTiming.beatLength / tickRate
        : 0.0;

    final double tickProgressStep = (tickInterval > 0 && slideDuration > 0)
        ? tickInterval / slideDuration
        : 0.0;

    // Calculate path if not created at runtime.
    addNestedHitObject(
      SliderHead(parent: this, spanIndex: 0)
        ..position = pathPoints.first
        ..time = time,
    );

    for (int span = 0; span < slides; span++) {
      final spanTime = time + (span * slideDuration);
      final isReversed = span.isOdd;

      if (tickProgressStep > 0 && tickProgressStep < 1.0) {
        double progress = tickProgressStep;

        while (progress < 1.0 - (tickProgressStep / 8)) {
          final double t = isReversed ? (1.0 - progress) : progress;
          final int tickTime = (spanTime + (progress * slideDuration)).round();

          addNestedHitObject(
            // Ticks dont have angle
            SliderTick(parent: this, spanIndex: span)
              ..position = positionAt(t)
              ..time = tickTime,
          );

          progress += tickProgressStep;
        }
      }

      if (span < slides - 1) {
        final int repeatTime = (spanTime + slideDuration).round();

        addNestedHitObject(
          SliderRepeat(parent: this, spanIndex: span)
            ..position = pathPoints.isEmpty
                // Prevent OOB error
                ? SPINNER_CENTRE
                : isReversed
                ? pathPoints.first
                : pathPoints.last
            ..time = repeatTime
            ..angle = _angleAt(isReversed ? 0.0 : 1.0 - EPSILON),
        );
      }
    }

    addNestedHitObject(
      SliderEnd(parent: this, spanIndex: slides - 1)
        ..position = endPosition
        ..time = endTime,
    );
  }

  double _angleAt(double t) {
    final current = positionAt(min(t, 1.0 - EPSILON));
    final next = positionAt(min(t + EPSILON, 1.0));

    return (next - current).direction;
  }
}
