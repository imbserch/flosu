part of '../base.dart';

class HitObjectDrawable<T extends HitObject> extends PlayfieldDrawable {
  HitObjectDrawable({
    required this.hitObject,
    // required this.metadata,
    required this.difficulty,
    required this.mods,
  });

  final T hitObject;

  /// Beatmap difficulty settings, used to derive circle radius, timing
  /// windows, and approach-circle size.
  // final BeatmapMetadata metadata;
  final BeatmapDifficultyMetadata difficulty;

  /// Active mods. Used to adjust rendering (e.g. [Hidden] changes opacity).
  final Set<ConfigurableMod> mods;

  late final double radius = difficulty.circleRadius;
  late final double diameter = 2 * radius;

  @override
  bool isExpired(int position) => !hitObject.canShow(position, difficulty);

  @override
  void paint(Canvas c, int position) {
    //
    super.paint(c, position);
  }
}
