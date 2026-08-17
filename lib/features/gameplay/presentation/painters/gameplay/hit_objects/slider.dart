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
    required super.difficulty,
    required super.mods,
    required super.comboColor,
    required super.comboNumber,
  }) {
    //

    // Simulate slider being hold at hitTime
    sliderHandled(hitObject.time.toDouble());
  }

  @override
  bool isExpired(double position) {
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
  bool _enableSnake = false;
  bool get enableSnake => _enableSnake;

  set enableSnake(bool value) {
    if (_enableSnake != value) {
      _enableSnake = value;
      _cachedVersion = 0;
      _cachedPath.reset();
    }
  }

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

  late final Color borderColor = comboColor;
  late final Color backgroundColor = Color.lerp(
    comboColor,
    Colors.black,
    2 / 3,
  )!;

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

    final slideElapsed = elapsed % hitObject.slideDuration;
    final slideProgress = slideElapsed / hitObject.slideDuration;

    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ hitObject.slideDuration;
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
    final slideIdx = elapsed ~/ hitObject.slideDuration;
    return slideIdx.isEven ? 1 : -1;
  }

  // If the path needs recomputation before using it
  int _pathNeedsUpdate(double position) {
    if (!enableSnake) return _cachedVersion;

    // If the slider is growing because it will appear
    // 16 ms is the threshold for slider full render
    if (position <= hitObject.time - difficulty.preempt / 6) {
      return _cachedVersion + 1;
    }

    final lastSlideStartTime =
        hitObject.time + (hitObject.slides - 1) * hitObject.slideDuration;

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

    if (position > hitObject.endTime) return [];

    // If the slider is growing because it will appear
    // at any moment
    if (position < hitObject.time) {
      final shrink = hitObject.time - difficulty.preempt;
      final expanded =
          hitObject.time - (difficulty.preempt * (1 - HIDDEN_FADE_IN_MULT));

      final progress = Interpolation.inverseLerp(shrink, expanded, position);
      final index = hitObject.indexAt(progress);
      final offset = hitObject.positionAt(progress);

      final points = hitObject.pathPoints.sublist(0, max(0, index));
      return [...points, offset];
    }

    final lastSlideStartTime =
        hitObject.time + (hitObject.slides - 1) * hitObject.slideDuration;

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
      final offset = hitObject.positionAt(progress);

      // If is forward: slider is drawing from index to end (0 to n)
      // If is backward: slider is drawing from 0 to index
      final points = isForward
          ? hitObject.pathPoints.sublist(index)
          : hitObject.pathPoints.sublist(0, index);

      // If is forward, add interpolated offset at the beggining
      // If is backward, add interpolated offset at the end
      final output = [if (isForward) offset, ...points, if (!isForward) offset];
      return output;
    }

    return hitObject.pathPoints;
  }

  @override
  void paint(Canvas c, double position) {
    super.paint(c, position);

    _paintBody(c, position);

    for (final nestedObject in hitObject.nestedHitObjects) {
      switch (nestedObject) {
        case SliderTick tick:
          _paintTick(c, position, tick);
          break;
        case SliderRepeat repeat:
          _paintRepeat(c, position, repeat);
          break;
        case SliderEnd _:
          // Osu!lazer Argon skin don't draw ends
          break;

        case SliderHead _:
          if (position < hitObject.time) {
            HitCircleDrawable.paintHitCircle(
              c,
              position,
              comboColor,
              comboNumber,
              difficulty,
              hitObject,
              mods,
            );
          }
          break;
      }
    }

    if (position >= hitObject.time) _paintBall(c, position);
  }

  void _paintTick(Canvas c, double position, SliderTick tick) {
    if (position >= tick.time) return;

    final slideTime =
        hitObject.time + (tick.spanIndex * hitObject.slideDuration);

    final tickDelta = (tick.time - slideTime) / 2;

    final opacity = Interpolation.inverseLerp(
      tick.time - tickDelta - 80,
      tick.time - tickDelta,
      position,
    ).clamp(0.0, 1.0);

    if (opacity == 0.0) return;

    c.drawArc(
      .fromCircle(center: tick.position, radius: radius / 16),
      0,
      2 * pi,
      false,
      Paint()
        ..style = .stroke
        ..color = borderColor.withValues(alpha: opacity)
        ..strokeWidth = radius / 16
        ..strokeCap = .round,
    );
  }

  void _paintRepeat(Canvas c, double position, SliderRepeat repeat) {
    if (position > repeat.time) return;

    final opacity = Interpolation.inverseLerp(
      repeat.time - (hitObject.slideDuration * 1 - HIDDEN_FADE_IN_MULT),
      repeat.time - (hitObject.slideDuration * HIDDEN_FADE_OUT_MULT),
      position,
    ).clamp(0.0, 1.0);

    if (opacity == 0.0) return;

    c
      ..save()
      ..translate(repeat.position.dx, repeat.position.dy)
      ..rotate(repeat.angle)
      ..drawPoints(
        .lines,
        [const Offset(-10, 0), const Offset(10, 0)],
        _arrowPaint
          ..strokeWidth = radius / 2
          ..color = Colors.white.withValues(alpha: opacity),
      )
      ..rotate(repeat.spanIndex.isOdd ? 0 : pi)
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
      ..drawArc(
        .fromCircle(center: .zero, radius: radius),
        pi / 2,
        pi,
        false,
        _arrowPaint
          ..strokeWidth = radius / 6
          ..color = Colors.white.withValues(alpha: opacity),
      )
      ..restore();
    ;
  }

  void _paintBody(Canvas c, double position) {
    final isHidden = mods.containsMod(.hidden);
    final isTraceable = mods.containsMod(.traceable);

    late double opacity;

    final preempt = difficulty.preempt;

    final preemptTime = hitObject.time - preempt;

    // Preempt * 0.3
    final fadeOutTime = (preempt * HIDDEN_FADE_OUT_MULT);

    switch (position) {
      // Hidden fade out (Doesn't count snaking)
      case _ when (isHidden || isTraceable) && position >= hitObject.time:
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
          _cachedPath
            ..reset()
            ..addPolygon(_sliderPoints(position), false);
          _cachedVersion = version;
        }
      case false:
        // Only add points if not added yet
        if (_cachedVersion == 0) {
          _cachedPath
            ..reset()
            ..addPolygon(hitObject.pathPoints, false);
          _cachedVersion = 1;
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

  /// Draws the animated slider ball at the position corresponding to
  /// the current audio [position].
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
      final full = shrink + difficulty.preempt / 6;

      final relativeT = ((position - shrink) / (full - shrink));
      t = Curves.easeOut.transform(relativeT.clamp(0.0, 1.0));

      scale = 1 + t;
    } else {
      final full = _sliderHandlePosition;
      final overflow = full + difficulty.preempt / 6;

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
