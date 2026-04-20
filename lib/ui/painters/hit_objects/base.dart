import 'dart:math';

import 'package:flutter/material.dart' hide Slider;
import 'package:flosu/core/extensions.dart';
import 'package:flosu/core/math/geometry.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/mods/base.dart';

part "hit_circle.dart";
part "slider.dart";
part "spinner.dart";

sealed class HitObjectPainter {
  HitObjectPainter(this.position, this.difficulty, this.mods);

  final int position;
  final BeatmapDifficulty difficulty;
  final Set<ConfigurableMod> mods;

  //This is for save layers for semitransparent objects
  void saveLayer(Canvas c, double opacity) {
    if (opacity >= 1) return;

    c.saveLayer(
      null,
      Paint()..color = Colors.white.withAlpha((255 * opacity).round()),
    );
  }

  //This is for restore layers for semitransparent objects
  void restoreLayer(Canvas c, double opacity) {
    if (opacity >= 1) return;

    c.restore();
  }

  void paint(Canvas c, Size s);
}
