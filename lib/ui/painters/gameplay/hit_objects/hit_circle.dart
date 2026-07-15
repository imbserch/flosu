import 'dart:math';

import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/storage/beatmap_metadata.dart';
import 'package:flosu/ui/painters/gameplay/base.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';

class HitCircleDrawable extends HitObjectDrawable<HitCircle> {
  HitCircleDrawable({
    required super.hitObject,
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
  void paint(Canvas c, int position) {
    super.paint(c, position);

    // Directly paint from helper function
    paintHitCircle(c, position, difficulty, hitObject, mods);
  }

  static void paintHitCircle(
    Canvas c,
    int position,
    BeatmapDifficultyMetadata difficulty,
    HitObject hitObject,
    Set<ConfigurableMod> mods,
  ) {
    final Color primaryColor = hitObject.color;
    final Color secondaryColor = Color.lerp(primaryColor, Colors.black, 1 / 3)!;
    final Color tertiaryColor = Color.lerp(primaryColor, Colors.black, 2 / 3)!;

    final center = hitObject is Slider ? hitObject.points.first : hitObject.pos;
    final radius = difficulty.circleRadius;

    final fullSize = hitObject.hitTime - difficulty.preemptFullOp;
    final isHidden = mods.containsMod(.hidden);

    // Default values
    double opacity = 1.0;
    double scale = 1.0;

    // Opacity calculations
    if (position <= fullSize) {
      final hidden = hitObject.hitTime - difficulty.preempt;
      final visible = hitObject.hitTime - difficulty.preemptFullOp;

      // Use fade in
      final t = ((position - hidden) / (visible - hidden));
      opacity = t.clamp(0.0, 1.0);
    } else {
      if (isHidden) {
        final visible = hitObject.hitTime - difficulty.preemptFullOp;
        final hidden = hitObject.hitTime;

        // Use fade out
        final t = ((position - visible) / (hidden - visible));
        opacity = 1.0 - t.clamp(0.0, 1.0);
      }
      // Object is fully visible (opacity = 1.0)
    }

    // Return early if opacity is 0
    if (opacity == 0) return;

    // Approach circle scaling calculations
    if (position < hitObject.hitTime) {
      final expanded = hitObject.hitTime - difficulty.preempt;
      final shrink = hitObject.hitTime;

      final t = ((position - expanded) / (shrink - expanded));
      scale = 4 - 3 * t.clamp(0.0, 1.0);
    }

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

    // Combo number.
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${hitObject.comboIdx}",
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
