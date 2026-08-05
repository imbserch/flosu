part of '../base.dart';

class HitObjectDrawable<T extends HitObject> extends PlayfieldDrawable {
  HitObjectDrawable({
    required this.hitObject,
    required this.beatmap,
    required this.difficulty,
    required this.mods,
  });

  final T hitObject;

  /// Beatmap of this hit object belongs to.
  final Beatmap beatmap;

  final Difficulty difficulty;

  /// Active mods. Used to adjust rendering (e.g. [Hidden] changes opacity).
  final Set<Mod> mods;

  late final double radius = beatmap.difficulty.radius;
  late final double diameter = 2 * radius;

  @override
  void paint(Canvas c, double position) {
    //
    super.paint(c, position);
  }
}
