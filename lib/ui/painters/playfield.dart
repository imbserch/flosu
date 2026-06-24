import 'package:flutter/material.dart' hide Slider;
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/ui/painters/hit_objects/base.dart';

/// A [CustomPainter] that renders all visible [HitObject]s onto the playfield.
///
/// [PlayfieldPainter] is driven by two [ValueNotifier]s:
/// - [position]: the current audio position in milliseconds.
/// - [objects]:  the list of hit objects currently visible.
///
/// When either notifier changes, Flutter schedules a repaint automatically.
/// The painter delegates to the appropriate [HitObjectPainter] subclass for
/// each object type via an exhaustive `switch` expression.
class PlayfieldPainter extends CustomPainter {
  PlayfieldPainter({
    required this.position,
    required this.objects,
    required this.difficulty,
    required this.snakingSliders,
    required this.mods,
  }) : super(repaint: Listenable.merge([position, objects]));

  /// Current audio playback position in milliseconds.
  final ValueNotifier<int> position;

  /// The hit objects that should be drawn in the current frame.
  ///
  /// Provided in reverse chronological order so that earlier objects
  /// (which must appear on top) are drawn last.
  final ValueNotifier<List<HitObject>> objects;

  /// Beatmap difficulty settings used by each sub-painter to derive sizes
  /// and timing-window-dependent rendering.
  final BeatmapDifficulty difficulty;

  /// Whether to animate the slider body growing out from the head.
  final bool snakingSliders;

  /// Active mods passed to sub-painters (e.g. [Hidden] changes opacity).
  final Set<ConfigurableMod> mods;

  @override
  void paint(Canvas c, Size s) {
    final hitObjects = objects.value;
    final position = this.position.value;

    for (final hitObject in hitObjects) {
      final HitObjectPainter painter = switch (hitObject) {
        HitCircle() => HitCirclePainter(hitObject, position, difficulty, mods),
        Slider() => SliderPainter(
          hitObject,
          position,
          difficulty,
          mods,
          snakingSliders,
        ),
        Spinner() => SpinnerPainter(hitObject, position, difficulty, mods),
      };

      painter.paint(c, s);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
