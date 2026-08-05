import 'dart:math';

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
    required super.beatmap,
    required super.difficulty,
    required super.mods,
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
    paintHitCircle(c, position, beatmap, hitObject, mods);
  }

  static void paintHitCircle(
    Canvas c,
    double position,
    Beatmap beatmap,
    HitObject hitObject,
    Set<Mod> mods,
  ) {
    final Color primaryColor = hitObject.color(beatmap);
    final Color secondaryColor = Color.lerp(primaryColor, Colors.black, 1 / 3)!;
    final Color tertiaryColor = Color.lerp(primaryColor, Colors.black, 2 / 3)!;

    final center = hitObject is Slider
        ? hitObject.pathPoints[0]
        : hitObject.position;

    final radius = beatmap.difficulty.radius;

    final fullSize = hitObject.time - beatmap.difficulty.preempt * (2 / 3);
    final isHidden = mods.containsMod(.hidden);
    final isTraceable = mods.containsMod(.traceable);

    // Default values
    late double opacity, scale;

    // Approach circle scaling calculations
    switch (position) {
      case _ when position < hitObject.time:
        final expanded = hitObject.time - beatmap.difficulty.preempt;
        final shrink = hitObject.time;

        final t = Interpolation.inverseLerp(expanded, shrink, position);
        scale = 4.0 - 3.0 * t.clamp(0.0, 1.0);
      case _:
        scale = 1.0;
    }

    // Opacity calculations
    switch (position) {
      // Circle is appearing
      case _ when position <= fullSize:
        final hidden = hitObject.time - beatmap.difficulty.preempt;
        final visible = hitObject.time - beatmap.difficulty.preempt * (2 / 3);

        // Use fade in
        final t = Interpolation.inverseLerp(hidden, visible, position);
        opacity = t.clamp(0.0, 1.0);
      // Circle is disappearing because the mod Hidden is active
      case _ when isHidden:
        final visible = hitObject.time - beatmap.difficulty.preempt * (2 / 3);
        final hidden = hitObject.time;

        // Use fade out
        final t = Interpolation.inverseLerp(visible, hidden, position);
        opacity = 1.0 - t.clamp(0.0, 1.0);
      // Circle is fully visible
      case _:
        opacity = 1.0;
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
      // Combo number.
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${hitObject.comboNumber(beatmap)}",
          style: textStyle.copyWith(
            fontSize: radius * (2 / 3),
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
        textDirection: .ltr,
      )..layout();

      final textOffset = Offset(textPainter.width / 2, textPainter.height / 2);

      textPainter.paint(c, center - textOffset);
    }
  }
}
