part of "base.dart";

class Classic extends ConfigurableMod {
  @override
  String get name => "Classic";

  @override
  String get acronym => "CL";

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
  @override
  String get acronym => "DA";

  @override
  String get description => "Override a beatmap's difficulty settings";

  @override
  String get name => "Difficulty Adjust";

  @override
  double get scoreMultiplier => 0.5;

  @override
  Color get color => AppColors.purple;

  @override
  bool get ranked => false;

  @override
  Set<ConfigurableMod> get incompatibleMods => {Easy(), HardRock()};
}
