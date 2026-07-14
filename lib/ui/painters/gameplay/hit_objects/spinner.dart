import 'dart:math';

import 'package:flosu/core/constants.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/ui/painters/gameplay/base.dart';
import 'package:flosu/ui/painters/gameplay/hit_objects/hit_circle.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';

class SpinnerDrawable extends HitObjectDrawable<Spinner> {
  SpinnerDrawable({
    required super.hitObject,
    required super.difficulty,
    required super.mods,
  });

  static final Paint _borderPaint = Paint()
    ..style = .stroke
    ..strokeCap = .round
    ..strokeJoin = .round
    ..strokeWidth = 1.0;

  late final _spmPainter = TextPainter(
    text: TextSpan(
      text: "SPINS PER MINUTE",
      style: HitCircleDrawable.textStyle.copyWith(
        fontSize: 14,
        fontWeight: .w500,
      ),
    ),
    textDirection: .ltr,
  );

  late final _spmCountStyle = HitCircleDrawable.textStyle.copyWith(
    fontSize: 22,
  );

  @override
  void paint(Canvas c, int position) {
    super.paint(c, position);

    c
      ..drawArc(
        .fromCircle(center: SPINNER_CENTRE, radius: 9),
        0,
        2 * pi,
        false,
        _borderPaint
          ..color = Colors.white
          ..strokeWidth = 9,
      )
      ..drawArc(
        .fromCircle(center: SPINNER_CENTRE, radius: 16),
        0,
        2 * pi,
        false,
        _borderPaint
          ..color = Colors.white
          ..strokeWidth = 3,
      )
      ..drawArc(
        .fromCircle(center: SPINNER_CENTRE, radius: 192),
        0,
        2 * pi,
        false,
        _borderPaint
          ..color = Colors.white
          ..strokeWidth = 9,
      );

    final sx = SPINNER_CENTRE.dx;

    // TODO: IMPLEMENT SPIN SPM
    final spmCountPainter = TextPainter(
      text: TextSpan(text: 0.toString(), style: _spmCountStyle),
      textDirection: .ltr,
    );

    spmCountPainter
      ..layout()
      ..paint(c, Offset(sx - spmCountPainter.width / 2, 252));

    _spmPainter
      ..layout()
      ..paint(c, Offset(sx - _spmPainter.width / 2, 280));
  }
}
