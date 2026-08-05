// ignore_for_file: non_constant_identifier_names

part of "mod.dart";

/// A mod that changes the behavior of the game
/// to match the behavior of osu!stable
//TODO: Implement configuration
class Classic extends ModificableMod {
  Classic([ModConfiguration? configuration])
    : super(ModInfo.classic, configuration);

  @override
  String get assetPath => AppMods.cl;

  @override
  String get description => "Feeling nostalgic?";

  @override
  double get scoreMultiplier => 0.98;

  @override
  Color get color => AppColors.purple;

  @override
  Set<ModInfo> get incompatibleMods => {ModInfo.strictTracking};
}

class DifficultyAdjust extends ModificableMod {
  DifficultyAdjust([ModConfiguration? configuration])
    : _internalDifficulty = configuration?.difficulty ?? Difficulty(),
      super(ModInfo.difficultyAdjust, configuration);

  final Difficulty _internalDifficulty;

  @override
  ModInfo get info => ModInfo.difficultyAdjust;

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
  Set<ModInfo> get incompatibleMods => {ModInfo.easy, ModInfo.hardRock};

  @override
  Difficulty applyTo(Difficulty difficulty) => _internalDifficulty;
}
