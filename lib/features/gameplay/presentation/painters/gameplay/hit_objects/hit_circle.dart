import 'dart:math';

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/core/math/interpolation.dart';
import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';

class HitCircleDrawable extends HitObjectDrawable<HitCircle> {
  HitCircleDrawable({
    required super.hitObject,
    required super.difficulty,
    required super.mods,
    required super.comboColor,
    required super.comboNumber,
  });

  static final Paint _bodyPaint = Paint()..strokeCap = .round;

  static final Paint _ringPaint = Paint()
    ..strokeCap = .round
    ..style = .stroke;

  static const TextStyle textStyle = TextStyle(
    fontFamily: "Torus",
    fontWeight: .w700,
    height: 1,
  );

  @override
  bool isExpired(double position) =>
      position > hitObject.time + difficulty.preempt;

  @override
  void paint(Canvas c, double position) {
    super.paint(c, position);

    // Directly paint from helper function
    paintHitCircle(
      c,
      position,
      comboColor,
      comboNumber,
      difficulty,
      hitObject,
      mods,
    );
  }

  static void paintHitCircle(
    Canvas c,
    double position,
    Color color,
    int number,
    Difficulty difficulty,
    HitObject hitObject,
    Set<Mod> mods,
  ) {
    final Color primaryColor = color;
    final Color secondaryColor = Color.lerp(color, Colors.black, 1 / 3)!;
    final Color tertiaryColor = Color.lerp(color, Colors.black, 2 / 3)!;

    final radius = difficulty.radius;
    final center = hitObject is Slider
        ? hitObject.pathPoints[0]
        : hitObject.position;

    final isHidden = mods.containsMod(.hidden);
    final isTraceable = mods.containsMod(.traceable);
    final isHardRock = mods.containsMod(.hardRock);

    // Default values
    late double opacity, scale;

    // Approach circle scaling calculations
    switch (position) {
      case _ when position < hitObject.time:
        final expanded = hitObject.time - difficulty.preempt;
        final shrink = hitObject.time;

        final t = Interpolation.inverseLerp(expanded, shrink, position);
        scale = 4.0 - 3.0 * t.clamp(0.0, 1.0);
      case _:
        scale = 1.0;
    }

    final preemptTime = hitObject.time - difficulty.preempt;

    // HitTime - preempt * 0.6
    final fadeInTime =
        hitObject.time - (difficulty.preempt * (1 - HIDDEN_FADE_IN_MULT));

    // HitTime - preempt * 0.3
    final fadeOutTime =
        hitObject.time - (difficulty.preempt * HIDDEN_FADE_IN_MULT);

    // Opacity calculations
    switch (position) {
      // Hidden fade out
      case _ when isHidden && position >= fadeInTime:
        final t = Interpolation.inverseLerp(fadeInTime, fadeOutTime, position);

        opacity = 1 - t.clamp(0.0, 1.0);

      // Hidden fade in
      case _ when isHidden && position >= preemptTime:
        final t = Interpolation.inverseLerp(preemptTime, fadeInTime, position);

        opacity = t.clamp(0.0, 1.0);

      // Normal fade out
      case _ when position >= preemptTime:
        final t = Interpolation.inverseLerp(preemptTime, fadeOutTime, position);
        opacity = t.clamp(0.0, 1.0);

      // Other cases: hidden
      case _:
        opacity = 0.0;
    }

    // Return early if opacity is 0
    if (opacity == 0) return;

    if (!isTraceable) {
      // Base circle
      c
        ..drawPoints(
          .points,
          [center],
          _bodyPaint
            ..strokeWidth = (28 / 16) * radius
            ..color = tertiaryColor.withValues(alpha: 0.8 * opacity),
        )
        // Inner ring
        ..drawArc(
          .fromCircle(center: center, radius: (17 / 24) * radius),
          0,
          2 * pi,
          false,
          _ringPaint
            ..strokeWidth = radius / 3
            ..color = secondaryColor.withValues(alpha: opacity),
        )
        // Outer ring
        ..drawArc(
          .fromCircle(center: center, radius: (19 / 24) * radius),
          0,
          2 * pi,
          false,
          _ringPaint
            ..strokeWidth = radius / 6
            ..color = primaryColor.withValues(alpha: opacity),
        )
        // White border
        ..drawArc(
          .fromCircle(center: center, radius: radius),
          0,
          2 * pi,
          false,
          _ringPaint
            ..strokeWidth = radius / 16
            ..color = Colors.white.withValues(alpha: opacity),
        );
    }

    // Approach circle
    if (scale > 1 && !isHidden) {
      c.drawArc(
        .fromCircle(center: center, radius: scale * radius),
        0,
        2 * pi,
        false,
        _ringPaint
          ..color = primaryColor.withValues(alpha: opacity)
          ..strokeWidth = (radius / 16) * scale,
      );
    }

    if (!isTraceable) {
      if (isHardRock) {
        c
          ..save()
          ..translate(center.dx, center.dy)
          ..scale(1, -1)
          ..translate(-center.dx, -center.dy);
      }

      // Combo number.
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$number",
          style: textStyle.copyWith(
            fontSize: radius * (2 / 3),
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
        textDirection: .ltr,
      )..layout();

      final textOffset = Offset(textPainter.width / 2, textPainter.height / 2);

      textPainter.paint(c, center - textOffset);

      if (isHardRock) c.restore();
    }
  }
}
