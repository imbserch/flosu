part of "mod.dart";

/// A mod that reduces the difficulty of the beatmap.
class Easy extends ModificableMod {
  Easy([ModConfiguration? configuration])
    : extraLives = configuration?.extraLives ?? 2,
      super(ModInfo.easy, configuration);

  /// The amount of extra lives the player has.
  final int extraLives;

  @override
  String get description =>
      "Larger circles, more forgiving HP drain,"
      "less accuracy required, and three lives!";

  @override
  String get assetPath => AppMods.ez;

  @override
  // Osu!lazer recently updated this value
  double get scoreMultiplier => extraLives == 2 ? 0.8 : 0.6;

  @override
  bool get ranked => extraLives == 2;

  @override
  Color get color => AppColors.green;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.hardRock,
    ModInfo.accuracyChallenge,
    ModInfo.difficultyAdjust,
  };

  @override
  Difficulty applyTo(Difficulty difficulty) {
    final newDifficulty = Difficulty()
      ..circleSize = (difficulty.circleSize * 0.5).clamp(0, 10)
      ..approachRate = (difficulty.approachRate * 0.5).clamp(0, 10)
      ..overallDifficulty = (difficulty.overallDifficulty * 0.5).clamp(0, 10)
      ..hpDrain = (difficulty.hpDrain * 0.5).clamp(0, 10)
      ..sliderMultiplier = difficulty.sliderMultiplier
      ..sliderTickRate = difficulty.sliderTickRate;

    return newDifficulty;
  }
}

/// A mod that prevents the player from failing the beatmap.
class NoFail extends Mod {
  NoFail() : super(ModInfo.noFail);

  @override
  String get assetPath => AppMods.nf;

  @override
  String get description => "You can't fail, no matter what";

  @override
  double get scoreMultiplier => 0.5;

  @override
  Color get color => AppColors.green;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.accuracyChallenge,
    ModInfo.perfect,
    ModInfo.suddenDeath,
    ModInfo.cinema,
  };
}

/// A mod that reduces the speed of the beatmap.
class HalfTime extends AudioModificableMod {
  HalfTime([ModConfiguration? configuration])
    : speedDecrease = configuration?.speedDecrease ?? 0.75,
      adjustPitch = configuration?.adjustPitch ?? false,
      super(ModInfo.halfTime, configuration);

  /// The final rate of audio
  final double speedDecrease;

  /// If the audio should match rate pitch
  final bool adjustPitch;

  @override
  String get assetPath => AppMods.ht;

  @override
  String get description => "Less zoom...";

  @override
  // TODO: Use formula of score multiplier used in osu!lazer
  double get scoreMultiplier => 0.55;

  @override
  Color get color => AppColors.green;

  @override
  double get rate => speedDecrease.clamp(0.5, 0.99);

  @override
  double get pitch => adjustPitch ? rate : 1.0;

  @override
  bool get ranked => rate == 0.75;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.daycore,
    ModInfo.doubleTime,
    ModInfo.nightcore,
    // AdaptiveSpeed,
    // WindUp,
    // WindDown,
  };
}

/// A mod like HalfTime but with a lower pitch
class Daycore extends AudioModificableMod {
  Daycore([ModConfiguration? configuration])
    : speedDecrease = configuration?.speedDecrease ?? 0.75,
      super(ModInfo.daycore, configuration);

  /// The final rate of audio
  final double speedDecrease;

  @override
  ModInfo get info => ModInfo.daycore;

  @override
  String get assetPath => AppMods.dc;

  @override
  String get description => "Whoaaaaa...";

  @override
  // TODO: Use formula of score multiplier used in osu!lazer
  double get scoreMultiplier => 0.3;

  @override
  Color get color => AppColors.green;

  @override
  double get rate => speedDecrease.clamp(0.5, 0.99);

  @override
  double get pitch => 0.75;

  @override
  bool get ranked => rate == 0.75;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.halfTime,
    ModInfo.doubleTime,
    ModInfo.nightcore,
    // AdaptiveSpeed,
    // WindUp,
    // WindDown,
  };
}
