part of '../base.dart';

class HitObjectDrawable<T extends HitObject> extends PlayfieldDrawable {
  factory HitObjectDrawable.create(
    HitObject hitObject,
    Beatmap beatmap,
    Difficulty difficulty,
    Set<Mod> mods,
    bool enableSnake,
  ) {
    final idx = beatmap.hitObjects.lowerBoundBy(hitObject, (ho) => ho.time);

    final lastComboResetIdx = beatmap.hitObjects.lastIndexWhere(
      (ho) => ho.comboSkip != 0 && ho.time <= hitObject.time,
    );

    final comboNumber = lastComboResetIdx == -1
        ? idx + 1
        : idx - lastComboResetIdx + 1;

    late final colorIdx = beatmap.hitObjects
        .take(idx + 1)
        .fold<int>(0, (i, ho) => i + ho.comboSkip);

    late final comboColor = beatmap.colors[colorIdx % beatmap.colors.length];

    return switch (hitObject) {
          NestedHitObject() => throw UnimplementedError(
            "Nested hit objects not supported yet",
          ),
          HitCircle() => HitCircleDrawable(
            hitObject: hitObject,
            difficulty: difficulty,
            mods: mods,
            comboColor: comboColor,
            comboNumber: comboNumber,
          ),
          Slider() => SliderDrawable(
            hitObject: hitObject,
            difficulty: difficulty,
            mods: mods,
            comboColor: comboColor,
            comboNumber: comboNumber,
          )..enableSnake = enableSnake,
          Spinner() => SpinnerDrawable(
            hitObject: hitObject,
            difficulty: difficulty,
            mods: mods,
            comboColor: comboColor,
            comboNumber: comboNumber,
          ),
        }
        as HitObjectDrawable<T>;
  }

  HitObjectDrawable({
    required this.hitObject,
    required this.difficulty,
    required this.mods,
    required this.comboNumber,
    required this.comboColor,
  });

  final int comboNumber;
  final Color comboColor;

  final T hitObject;

  final Difficulty difficulty;

  /// Active mods. Used to adjust rendering (e.g. [Hidden] changes opacity).
  final Set<Mod> mods;

  double get radius => difficulty.radius;
  double get diameter => 2 * radius;

  @override
  void paint(Canvas c, double position) {
    //
    super.paint(c, position);
  }
}
