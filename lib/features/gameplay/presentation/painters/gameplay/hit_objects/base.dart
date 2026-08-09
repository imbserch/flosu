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

  late final idx = beatmap.hitObjects.lowerBoundBy(hitObject, (ho) => ho.time);

  late final _lastComboResetIdx = beatmap.hitObjects.lastIndexWhere(
    (ho) => ho.comboSkip != 0 && ho.time <= hitObject.time,
  );

  late final comboNumber = _lastComboResetIdx == -1
      ? idx + 1
      : idx - _lastComboResetIdx + 1;

  late final _colorIdx = beatmap.hitObjects
      .take(idx + 1)
      .fold<int>(0, (i, ho) => i + ho.comboSkip);

  late final color = beatmap.colors[_colorIdx % beatmap.colors.length];

  @override
  void paint(Canvas c, double position) {
    //
    super.paint(c, position);
  }
}
