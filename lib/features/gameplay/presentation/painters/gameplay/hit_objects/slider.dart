import 'dart:math';

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/math/interpolation.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/hit_objects/hit_circle.dart';
import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flutter/material.dart' show Colors, Curves;
import 'package:flutter/painting.dart';

/// Drawable for sliders.
// Functionalities:
// Snaking animation
// Slider hold and release animations
class SliderDrawable extends HitObjectDrawable<Slider> {
  SliderDrawable({
    required super.hitObject,
    required super.beatmap,
    required super.difficulty,
    required super.mods,
  }) {
    // Simulate slider being hold at hitTime
    sliderHandled(hitObject.time.toDouble());
  }

  @override
  bool isExpired(double position) {
    // Ensure animations are rendered for some milliseconds after the end of the slider
    return position > hitObject.endTime + beatmap.difficulty.preempt;
  }

  static final Paint _bodyPaint = Paint()
    ..strokeCap = .round
    ..strokeJoin = .round;

  static final Paint _ballPaint = Paint()
    ..strokeCap = .round
    ..strokeJoin = .round;

  static final Paint _arrowPaint = Paint()
    ..style = .stroke
    ..strokeCap = .round
    ..strokeJoin = .round;

  // If this slider can snake
  bool enableSnake = false;

  // If the slider is hold by user,
  // the ball will appear at the current
  // position of the hand.
  // If the slider is not hold by user,
  // the ball disappear using a new sliderHandlePosition
  bool _sliderHandled = false;
  double _sliderHandlePosition = 0;

  /// Called when the user presses the slider handle.
  void sliderHandled(double position) {
    _sliderHandled = true;
    _sliderHandlePosition = position;
  }

  /// Called when the user releases the slider handle.
  void sliderReleased(double position) {
    _sliderHandled = false;
    _sliderHandlePosition = position;
  }

  final _cachedPath = Path();
  int _cachedVersion = 0;

  late final Color borderColor = color;
  late final Color backgroundColor = Color.lerp(color, Colors.black, 2 / 3)!;

  /// Normalised position of the slider ball along the full path, [0.0, 1.0].
  ///
  /// - Before the slider starts: 0.0 (ball is at the head).
  /// - During tracking: interpolated between 0 and 1 over [object.duration].
  /// - Exactly 0.5 at the midpoint of the first slide.
  double _ballProgress(double position) {
    if (position < hitObject.time) return 0.0;

    final elapsed = position - hitObject.time;

    if (elapsed >= hitObject.duration) {
      return hitObject.slides.isEven ? 0.0 : 1.0;
    }

    final slideElapsed = elapsed % hitObject.slideDuration(beatmap);
    final slideProgress = slideElapsed / hitObject.slideDuration(beatmap);

    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ hitObject.slideDuration(beatmap);
    return slideIdx.isEven ? slideProgress : 1.0 - slideProgress;
  }

  int _ballDirection(double position) {
    if (position < hitObject.time) {
      return hitObject.slides.isEven ? 1 : -1;
    }

    final elapsed = position - hitObject.time;

    if (elapsed >= hitObject.duration) {
      return hitObject.slides.isEven ? -1 : 1;
    }
    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ hitObject.slideDuration(beatmap);
    return slideIdx.isEven ? 1 : -1;
  }

  // If the path needs recomputation before using it
  int _pathNeedsUpdate(double position) {
    if (!enableSnake) return _cachedVersion;

    // If the slider is growing because it will appear
    // 16 ms is the threshold for slider full render
    if (position <= hitObject.time - beatmap.difficulty.preempt / 6) {
      return _cachedVersion + 1;
    }

    final lastSlideStartTime =
        hitObject.time +
        (hitObject.slides - 1) * hitObject.slideDuration(beatmap);

    if (position > lastSlideStartTime) {
      return _cachedVersion + 1;
    }

    return _cachedVersion;
  }

  // This method should be expensive because of
  // List allocations every frame if snaking is enabled
  List<Offset> _sliderPoints(double position) {
    // Keep this conditional:
    // if slider cache is removed, this will keep working
    if (!enableSnake) return hitObject.pathPoints;

    return hitObject.pathPoints;
  }

  @override
  void paint(Canvas c, double position) {
    super.paint(c, position);

    _paintBody(c, position);
    _paintEnds(c, position);

    // if (position >= hitObject.time) _paintBall(c, position);

    // Paint using hit circle
    if (position < hitObject.time) {
      HitCircleDrawable.paintHitCircle(
        c,
        position,
        color,
        comboNumber,
        beatmap,
        hitObject,
        mods,
      );
    }
  }

  void _paintBody(Canvas c, double position) {
    final isHidden = mods.containsMod(.hidden);
    final isTraceable = mods.containsMod(.traceable);

    late double opacity;

    final preempt = beatmap.difficulty.preempt;

    final preemptTime = hitObject.time - preempt;

    // Preempt * 0.3
    final fadeOutTime = (preempt * HIDDEN_FADE_OUT_MULT);

    switch (position) {
      // Hidden fade out (Doesn't count snaking)
      case _ when isHidden && position >= hitObject.time:
        final t = Interpolation.inverseLerp(
          hitObject.endTime,
          hitObject.time,
          position,
        );

        opacity = Curves.easeOut.transform(t.clamp(0.0, 1.0));

      // Normal fade out: enable snake is not active (prevent slider "pop")
      case _
          when (!isHidden && !isTraceable) &&
              (!enableSnake && position >= hitObject.endTime):
        final t = Interpolation.inverseLerp(
          hitObject.endTime + fadeOutTime,
          hitObject.endTime,
          position,
        );

        opacity = t.clamp(0.0, 1.0);

      // Normal fade in
      case _ when position >= preemptTime:
        final t = Interpolation.inverseLerp(
          preemptTime,
          preemptTime + fadeOutTime,
          position,
        );
        opacity = t.clamp(0.0, 1.0);

      // Other cases: hidden
      case _:
        opacity = 0.0;
    }

    if (opacity == 0) return;

    switch (enableSnake) {
      case true:
        final version = _pathNeedsUpdate(position);

        // Check if path need to be recomputed
        if (version > _cachedVersion) {
          final sliderPoints = _sliderPoints(position);

          if (_cachedVersion != 0) _cachedPath.reset();
          _cachedPath.addPolygon(sliderPoints, false);

          _cachedVersion = version;
        }
      case false:
        // Only add points if not added yet
        if (_cachedVersion == 0) {
          _cachedPath.addPolygon(hitObject.pathPoints, false);
        }
    }

    c
      // Save layer (keep opacity because this is needed for path blend modes)
      ..saveLayer(
        null,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      )
      // Border
      ..drawPath(
        _cachedPath,
        _bodyPaint
          ..blendMode = .srcOver
          ..style = .stroke
          ..color = borderColor
          ..strokeWidth = diameter * 0.875,
      )
      // Clear border-covered surface (not the surface itself)
      // used by background
      ..drawPath(
        _cachedPath,
        _bodyPaint
          ..blendMode = .clear
          ..style = .stroke
          ..color = backgroundColor
          ..strokeWidth = diameter * 0.7,
      );

    if (!isTraceable) {
      // Background
      c.drawPath(
        _cachedPath,
        _bodyPaint
          ..blendMode = .srcOver
          ..style = .stroke
          ..color = backgroundColor.withValues(alpha: 0.8)
          ..strokeWidth = diameter * 0.7,
      );
    }

    // Restore layer
    c.restore();
  }

  void _paintEnds(Canvas c, double position) {
    // Don't paint first paint because
    // hitCircle is considered an end.
    final ends = hitObject.slides - 1;

    if (ends <= 0) return;

    for (int i = 0; i < ends; i++) {
      double opacity = 1.0, scale = 1.0;
      late Offset pointA, pointB;

      final isForward = (i + 1).isEven;
      final endTime =
          hitObject.time + (i + 1) * hitObject.slideDuration(beatmap);

      if (position < endTime) {
        final hidden = endTime - (beatmap.difficulty.preempt / 6);
        final visible = endTime;

        final t = ((position - hidden) / (visible - hidden));
        opacity = t.clamp(0.0, 1.0);
      } else {
        final start = endTime;
        final end = endTime + (beatmap.difficulty.preempt / 12);

        final t = ((position - start) / (end - start));

        opacity = 1 - t.clamp(0.0, 1.0);
        scale = (3 / 2) - (opacity / 2);
      }

      if (opacity == 0) continue;

      if (isForward) {
        // Forward
        pointA = hitObject.positionAt(0);
        pointB = hitObject.positionAt(EPSILON);
      } else {
        pointA = hitObject.positionAt(1);
        pointB = hitObject.positionAt(1 - EPSILON);
      }

      final angle = (pointB - pointA).direction + (pi / 2);

      final offsetDirection = Offset.fromDirection(angle - pi / 2, radius / 4);

      final reverseAPoint = pointA - offsetDirection;
      final reverseBPoint = pointA + offsetDirection;

      c.drawPoints(
        .lines,
        [reverseAPoint, reverseBPoint],
        _arrowPaint
          ..strokeWidth = scale * (radius / 2)
          ..color = Colors.white.withValues(alpha: opacity),
      );

      c
        ..save()
        ..translate(pointA.dx, pointA.dy)
        ..rotate(angle - (pi / 2))
        ..drawPoints(
          .polygon,
          // Arrow shape: ^
          [
            Offset(-radius / 32, radius / 8),
            Offset(radius / 32, 0),
            Offset(-radius / 32, -radius / 8),
          ],
          _arrowPaint
            ..strokeWidth = radius / 16
            ..color = backgroundColor,
        )
        ..restore();

      c.drawArc(
        .fromCircle(center: pointA, radius: scale * radius),
        angle,
        pi,
        false,
        _arrowPaint
          ..strokeWidth = radius / 6
          ..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  /// Draws the animated slider ball at the position corresponding to
  /// the current audio [position].
  // TODO (imbserch): Fix buggy implementation
  // ignore: unused_element
  void _paintBall(Canvas c, double position) {
    // If slider has ended, set slider release
    if (position > hitObject.endTime && _sliderHandled) {
      sliderReleased(position);
    }

    final progress = _ballProgress(position);
    final direction = _ballDirection(position);

    final current = hitObject.positionAt(min(progress, 1.0 - EPSILON));
    final next = hitObject.positionAt(min(progress + EPSILON, 1.0));

    final angle = (next - current).direction;

    final bx = (radius * direction) / 16;
    final by = radius / 4;

    late double t, scale;

    if (_sliderHandled) {
      final shrink = _sliderHandlePosition;
      final full = shrink + beatmap.difficulty.preempt / 6;

      final relativeT = ((position - shrink) / (full - shrink));
      t = Curves.easeOut.transform(relativeT.clamp(0.0, 1.0));

      scale = 1 + t;
    } else {
      final full = _sliderHandlePosition;
      final overflow = full + beatmap.difficulty.preempt / 6;

      final relativeT = ((position - full) / (overflow - full));
      t = 1 - Curves.easeOut.transform(relativeT.clamp(0.0, 1.0));

      scale = 2.5 - (t / 2);
    }

    if (t == 0) return;

    // Apply transformations
    c
      ..save()
      ..translate(current.dx, current.dy)
      ..rotate(angle);

    // Ball threshold circle with opacity
    c
      ..drawCircle(
        .zero,
        radius * scale,
        _ballPaint
          ..style = .fill
          ..color = borderColor.withValues(alpha: t / 4),
      )
      // Ball threshold ring
      ..drawCircle(
        .zero,
        radius * scale,
        _ballPaint
          ..style = .stroke
          ..strokeWidth = (radius / 8) * t
          ..color = borderColor.withValues(alpha: t),
      );

    // Don't draw ball after endTime
    if (position < hitObject.endTime) {
      // Ball border
      c
        ..drawCircle(
          .zero,
          radius * (7 / 8),
          _ballPaint
            ..style = .fill
            ..color = Colors.white.withValues(alpha: t),
        )
        // Ball background
        ..drawPoints(
          .points,
          [.zero],
          _ballPaint
            ..color = Color.lerp(
              borderColor,
              Colors.black,
              1 / 3,
            )!.withValues(alpha: t)
            ..strokeWidth = radius * (11 / 8),
          // Arrow shape: ^
        )
        ..drawPoints(
          .polygon,
          [Offset(-bx, -by), Offset(bx, 0), Offset(-bx, by)],
          _arrowPaint
            ..strokeWidth = radius / 8
            ..color = Colors.white.withValues(alpha: t),
        );
    }

    // Restore transformations
    c.restore();
  }
}
