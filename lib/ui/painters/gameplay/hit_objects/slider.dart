import 'dart:math';

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/ui/painters/gameplay/base.dart';
import 'package:flosu/ui/painters/gameplay/hit_objects/hit_circle.dart';
import 'package:flutter/material.dart' show Colors, Curves;
import 'package:flutter/painting.dart';

/// Drawable for sliders.
// Functionalities:
// Snaking animation
// Slider hold and release animations
class SliderDrawable extends HitObjectDrawable<Slider> {
  SliderDrawable({
    required super.hitObject,
    required super.difficulty,
    required super.mods,
  }) {
    // Simulate slider being hold at hitTime
    sliderHandled(hitObject.hitTime);
  }

  @override
  bool isExpired(int position) {
    // Ensure animations are rendered for some milliseconds after the end of the slider
    return position > hitObject.endTime + difficulty.preempt;
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
  int _sliderHandlePosition = 0;

  /// Called when the user presses the slider handle.
  void sliderHandled(int position) {
    _sliderHandled = true;
    _sliderHandlePosition = position;
  }

  /// Called when the user releases the slider handle.
  void sliderReleased(int position) {
    _sliderHandled = false;
    _sliderHandlePosition = position;
  }

  Path? _cachedPath;
  int _cachedVersion = 0;

  late final Color borderColor = hitObject.color;
  late final Color backgroundColor = Color.lerp(
    borderColor,
    Colors.black,
    2 / 3,
  )!;

  /// Normalised position of the slider ball along the full path, [0.0, 1.0].
  ///
  /// - Before the slider starts: 0.0 (ball is at the head).
  /// - During tracking: interpolated between 0 and 1 over [object.duration].
  /// - Exactly 0.5 at the midpoint of the first slide.
  double _ballProgress(int position) {
    if (position < hitObject.hitTime) return 0.0;

    final elapsed = position - hitObject.hitTime;

    if (elapsed >= hitObject.duration) {
      return hitObject.slides.isEven ? 0.0 : 1.0;
    }

    final slideElapsed = elapsed % hitObject.slideDuration;
    final slideProgress = slideElapsed / hitObject.slideDuration;

    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ hitObject.slideDuration;
    return slideIdx.isEven ? slideProgress : 1.0 - slideProgress;
  }

  int _ballDirection(int position) {
    if (position < hitObject.hitTime) {
      return hitObject.slides.isEven ? 1 : -1;
    }

    final elapsed = position - hitObject.hitTime;

    if (elapsed >= hitObject.duration) {
      return hitObject.slides.isEven ? -1 : 1;
    }
    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ hitObject.slideDuration;
    return slideIdx.isEven ? 1 : -1;
  }

  // If the path needs recomputation before using it
  int _pathNeedsUpdate(int position) {
    if (!enableSnake) return _cachedVersion;

    // If the slider is growing because it will appear
    // 16 ms is the threshold for slider full render
    if (position <= hitObject.hitTime - difficulty.preemptFullOp + 16) {
      return _cachedVersion + 1;
    }

    final lastSlideStartTime =
        hitObject.hitTime + (hitObject.slides - 1) * hitObject.slideDuration;

    if (position > lastSlideStartTime) {
      return _cachedVersion + 1;
    }

    return _cachedVersion;
  }

  // This method should be expensive because of
  // List allocations every frame if snaking is enabled
  List<Offset> _sliderPoints(int position) {
    // Keep this conditional:
    // if slider cache is removed, this will keep working
    if (!enableSnake) return hitObject.points;

    // If the slider is growing because it will appear
    // at any moment
    if (position < hitObject.hitTime) {
      final shrink = hitObject.hitTime - difficulty.preempt;
      final expanded = hitObject.hitTime - difficulty.preemptFullOp;

      final progress = (position - shrink) / (expanded - shrink);
      final index = hitObject.indexAt(progress);
      final offset = hitObject.pointAt(progress);

      final points = hitObject.points.sublist(0, max(0, index));
      return [...points, offset];
    }

    final lastSlideStartTime =
        hitObject.hitTime + (hitObject.slides - 1) * hitObject.slideDuration;

    // If the slider is shrinking
    // from full length because it's the last slide
    if (position > lastSlideStartTime) {
      final isForward = (hitObject.slides - 1).isEven;
      final expanded = lastSlideStartTime;

      // If is forward, progress goes from 0 to 1
      // If is backward, progress goes from 1 to 0
      final progress = isForward
          ? (position - expanded) / hitObject.slideDuration
          : 1.0 - (position - expanded) / hitObject.slideDuration;

      final index = hitObject.indexAt(progress);
      final offset = hitObject.pointAt(progress);

      // If is forward: slider is drawing from index to end (0 to n)
      // If is backward: slider is drawing from 0 to index
      final points = isForward
          ? hitObject.points.sublist(index)
          : hitObject.points.sublist(0, index);

      // If is forward, add interpolated offset at the beggining
      // If is backward, add interpolated offset at the end
      final output = [if (isForward) offset, ...points, if (!isForward) offset];
      return output;
    }

    return hitObject.points;
  }

  @override
  void paint(Canvas c, int position) {
    super.paint(c, position);

    _paintBody(c, position);
    _paintEnds(c, position);

    if (position >= hitObject.hitTime) _paintBall(c, position);

    // Paint using hit circle
    if (position < hitObject.hitTime) {
      HitCircleDrawable.paintHitCircle(
        c,
        position,
        difficulty,
        hitObject,
        mods,
      );
    }
  }

  void _paintBody(Canvas c, int position) {
    double opacity = 1.0;

    // Opacity calculations
    if (position <= hitObject.hitTime) {
      final hidden = hitObject.hitTime - difficulty.preempt;
      final visible = hitObject.hitTime - difficulty.preemptFullOp;

      // Use fade in before hitTime
      opacity = ((position - hidden) / (visible - hidden)).clamp(0.0, 1.0);
    } else {
      final hiddenEnabled = mods.containsMod(.hidden);

      if (hiddenEnabled) {
        final visible = hitObject.hitTime;
        final hidden = hitObject.hitTime + ((2 / 3) * hitObject.duration);

        // Use fade out before 2/3 of duration
        final t = ((position - visible) / (hidden - visible)).clamp(0.0, 1.0);
        opacity = 1.0 - Curves.easeOut.transform(t);
      } else {
        // Use fade out before endTime + preempt / 6
        if (position >= hitObject.endTime) {
          final visible = hitObject.endTime;
          final hidden = hitObject.endTime + difficulty.preemptFullOp / 2;

          final t = ((position - visible) / (hidden - visible)).clamp(0.0, 1.0);
          opacity = 1.0 - t;
        }
      }

      // Object is fully visible (opacity = 1.0)
    }

    if (opacity == 0) return;

    // Path calculations
    // Only compute path when snaking is enabled
    if (!enableSnake) {
      _cachedPath ??= Path()..addPolygon(hitObject.points, false);
    } else {
      final version = _pathNeedsUpdate(position);

      if (version > _cachedVersion) {
        final sliderPoints = _sliderPoints(position);

        if (_cachedPath != null) {
          (_cachedPath!..reset()).addPolygon(sliderPoints, false);
        } else {
          _cachedPath = Path()..addPolygon(sliderPoints, false);
        }

        _cachedVersion = version;
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
        _cachedPath!,
        _bodyPaint
          ..blendMode = .srcOver
          ..style = .stroke
          ..color = borderColor
          ..strokeWidth = diameter * 0.875,
      )
      // Clear border-covered surface (not the surface itself)
      // used by background
      ..drawPath(
        _cachedPath!,
        _bodyPaint
          ..blendMode = .clear
          ..style = .stroke
          ..color = backgroundColor
          ..strokeWidth = diameter * 0.7,
      )
      // Background
      ..drawPath(
        _cachedPath!,
        _bodyPaint
          ..blendMode = .srcOver
          ..style = .stroke
          ..color = backgroundColor.withValues(alpha: 0.8)
          ..strokeWidth = diameter * 0.7,
      )
      // Restore layer
      ..restore();
  }

  void _paintEnds(Canvas c, int position) {
    // Don't paint first paint because
    // hitCircle is considered an end.
    final ends = hitObject.slides - 1;

    if (ends <= 0) return;

    for (int i = 0; i < ends; i++) {
      double opacity = 1.0, scale = 1.0;
      late Offset pointA, pointB;

      final isForward = (i + 1).isEven;
      final endTime = hitObject.hitTime + (i + 1) * hitObject.slideDuration;

      if (position < endTime) {
        final hidden = endTime - (difficulty.preempt / 2);
        final visible = endTime;

        final t = ((position - hidden) / (visible - hidden));
        opacity = t.clamp(0.0, 1.0);
      } else {
        final start = endTime;
        final end = endTime + (difficulty.preempt / 4);

        final t = ((position - start) / (end - start));

        opacity = 1 - t.clamp(0.0, 1.0);
        scale = (3 / 2) - (opacity / 2);
      }

      if (opacity == 0) continue;

      if (isForward) {
        // Forward
        pointA = hitObject.pointAt(0);
        pointB = hitObject.pointAt(EPSILON);
      } else {
        pointA = hitObject.pointAt(1);
        pointB = hitObject.pointAt(1 - EPSILON);
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
  void _paintBall(Canvas c, int position) {
    // If slider has ended, set slider release
    if (position > hitObject.endTime && _sliderHandled) {
      sliderReleased(position);
    }

    final progress = _ballProgress(position);
    final direction = _ballDirection(position);

    final current = hitObject.pointAt(min(progress, 1.0 - EPSILON));
    final next = hitObject.pointAt(min(progress + EPSILON, 1.0));

    final angle = (next - current).direction;

    final bx = (radius * direction) / 16;
    final by = radius / 4;

    late double t, scale;

    if (_sliderHandled) {
      final shrink = _sliderHandlePosition;
      final full = shrink + difficulty.preemptFullOp / 2;

      final relativeT = ((position - shrink) / (full - shrink));
      t = Curves.easeOut.transform(relativeT.clamp(0.0, 1.0));

      scale = 1 + t;
    } else {
      final full = _sliderHandlePosition;
      final overflow = full + difficulty.preemptFullOp / 2;

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
