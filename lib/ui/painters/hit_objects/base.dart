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

/// Base class for all hit-object painters used on the playfield.
///
/// [HitObjectPainter] is `sealed` so that the parent [PlayfieldPainter] can
/// exhaustively switch over subtypes without a default case.
///
/// Each subclass receives the current audio [position], the beatmap
/// [difficulty], and the active [mods] set — the minimum context needed to
/// compute timing-dependent rendering (opacity, approach circles, etc.).
sealed class HitObjectPainter {
  HitObjectPainter(this.position, this.difficulty, this.mods);

  /// Current audio playback position in milliseconds.
  final int position;

  /// Beatmap difficulty settings, used to derive circle radius, timing
  /// windows, and approach-circle size.
  final BeatmapDifficulty difficulty;

  /// Active mods. Used to adjust rendering (e.g. [Hidden] changes opacity).
  final Set<ConfigurableMod> mods;

  /// Opens a compositing layer when [opacity] < 1 so that the entire object
  /// can be alpha-blended as a unit.
  ///
  /// A no-op when [opacity] is already 1 (fully opaque), avoiding unnecessary
  /// save-layer overhead.
  void saveLayer(Canvas c, double opacity) {
    if (opacity >= 1) return;

    c.saveLayer(
      null,
      Paint()..color = Colors.white.withAlpha((255 * opacity).round()),
    );
  }

  /// Closes the compositing layer opened by [saveLayer].
  ///
  /// Must be called with the same [opacity] value to ensure symmetry.
  void restoreLayer(Canvas c, double opacity) {
    if (opacity >= 1) return;

    c.restore();
  }

  /// Renders this hit object onto the given [Canvas].
  void paint(Canvas c, Size s);
}
