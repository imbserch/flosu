// ignore_for_file: non_constant_identifier_names

part of "base.dart";

class Classic extends ConfigurableMod {
  @override
  Mod get mod => Mod.classic;

  @override
  String get assetPath => AppMods.cl;

  @override
  String get description => "Feeling nostalgic?";

  @override
  double get scoreMultiplier => 0.96;

  @override
  Color get color => AppColors.purple;

  @override
  Set<ConfigurableMod> get incompatibleMods => {StrictTracking()};
}

class DifficultyAdjust extends ConfigurableMod {
  DifficultyAdjust({this.CS, this.AR, this.OD, this.HP});

  final double? CS;
  final double? AR;
  final double? OD;
  final double? HP;

  @override
  Mod get mod => Mod.difficultyAdjust;

  @override
  String get assetPath => AppMods.da;

  @override
  String get description => "Override a beatmap's difficulty settings";

  @override
  double get scoreMultiplier => 0.5;

  @override
  Color get color => AppColors.purple;

  @override
  bool get ranked => false;

  @override
  Set<ConfigurableMod> get incompatibleMods => {Easy(), HardRock()};

  @override
  BeatmapDifficultyMetadata applyTo(BeatmapDifficultyMetadata difficulty) {
    final newDifficulty = BeatmapDifficultyMetadata()
      ..ar = difficulty.ar
      ..cs = difficulty.cs
      ..od = difficulty.od
      ..hp = difficulty.hp
      ..sliderMultiplier = difficulty.sliderMultiplier
      ..sliderTickRate = difficulty.sliderTickRate;

    return newDifficulty;
  }
}
