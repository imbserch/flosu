import 'package:flutter/material.dart' hide Slider;
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/beatmap/hit_objects.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/ui/painters/hit_objects/base.dart';

class PlayfieldPainter extends CustomPainter {
  PlayfieldPainter({
    required this.position,
    required this.objects,
    required this.difficulty,
    required this.snakingSliders,
    required this.mods,
  }) : super(repaint: Listenable.merge([position, objects]));

  final ValueNotifier<int> position;
  final ValueNotifier<List<HitObject>> objects;
  final BeatmapDifficulty difficulty;
  final bool snakingSliders;
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
          snakingSliders,
          position,
          difficulty,
          mods,
        ),
        Spinner() => SpinnerPainter(position, difficulty, mods),
      };

      painter.paint(c, s);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
