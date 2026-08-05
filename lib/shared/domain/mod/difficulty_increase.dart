part of "mod.dart";

/// A mod that increases the difficulty of the beatmap.
class HardRock extends Mod {
  HardRock() : super(ModInfo.hardRock);

  @override
  String get assetPath => AppMods.hr;

  @override
  String get description => "Everything just got a bit harder...";

  @override
  double get scoreMultiplier => 1.09;

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {ModInfo.easy, ModInfo.difficultyAdjust};

  @override
  Difficulty applyTo(Difficulty difficulty) {
    final newDifficulty = Difficulty()
      ..circleSize = (difficulty.circleSize * 1.3).clamp(0, 10)
      ..approachRate = (difficulty.approachRate * 1.4).clamp(0, 10)
      ..overallDifficulty = (difficulty.overallDifficulty * 1.4).clamp(0, 10)
      ..hpDrain = (difficulty.hpDrain * 1.4).clamp(0, 10)
      ..sliderMultiplier = difficulty.sliderMultiplier
      ..sliderTickRate = difficulty.sliderTickRate;

    return newDifficulty;
  }
}

/// A mod that makes the player fail if they miss a note or slider
class SuddenDeath extends ModificableMod {
  SuddenDeath([ModConfiguration? configuration])
    : restartOnFail = configuration?.restartOnFail ?? false,
      failOnFailSliderTail = configuration?.failOnFailSliderTail ?? false,
      super(ModInfo.suddenDeath, configuration);

  /// If gameplay should restart when the player fails
  final bool restartOnFail;

  /// If gameplay should fail even if the player fails a slider's tail
  final bool failOnFailSliderTail;

  @override
  String get assetPath => AppMods.sd;

  @override
  String get description => "Miss and fail";

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.noFail,
    ModInfo.perfect,
    ModInfo.cinema,
    // TargetPractice,
  };
}

/// A mod like SuddenDeath but also fails if the player
/// doesn't hit perfectly every object
class Perfect extends ModificableMod {
  Perfect([ModConfiguration? configuration])
    : restartOnFail = configuration?.restartOnFail ?? false,
      super(ModInfo.perfect, configuration);

  /// If gameplay should restart when the player fails
  final bool restartOnFail;

  @override
  String get assetPath => AppMods.pf;

  @override
  String get description => "SS or quit";

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.noFail,
    ModInfo.suddenDeath,
    ModInfo.accuracyChallenge,
    ModInfo.cinema,
  };
}

/// A mod that increases the speed of the beatmap
class DoubleTime extends AudioModificableMod {
  DoubleTime([ModConfiguration? configuration])
    : speedIncrease = configuration?.speedIncrease ?? 1.5,
      adjustPitch = configuration?.adjustPitch ?? false,
      super(ModInfo.doubleTime, configuration);

  /// The final rate of audio
  final double speedIncrease;

  /// If the audio should match rate pitch
  final bool adjustPitch;

  @override
  String get assetPath => AppMods.dt;

  @override
  String get description => "Zoooooooooom...";

  @override
  // TODO: Use formula of score multiplier used in osu!lazer
  double get scoreMultiplier => 1.23;

  @override
  Color get color => AppColors.red;

  @override
  double get rate => speedIncrease.clamp(1.01, 2.0);

  @override
  double get pitch => adjustPitch ? rate : 1.0;

  @override
  bool get ranked => rate == 1.5;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.halfTime,
    ModInfo.daycore,
    ModInfo.nightcore,
    // AdaptiveSpeed,
    // WindUp,
    // WindDown,
  };
}

/// A mod like DoubleTime but with adjusted audio pitch
class Nightcore extends AudioModificableMod {
  Nightcore([ModConfiguration? configuration])
    : speedIncrease = configuration?.speedIncrease ?? 1.5,
      super(ModInfo.nightcore, configuration);

  /// The final rate of audio
  final double speedIncrease;

  @override
  String get assetPath => AppMods.nc;

  @override
  String get description => "Uguuuuuuuu...";

  @override
  // TODO: Use formula of score multiplier used in osu!lazer
  double get scoreMultiplier => 1.23;

  @override
  Color get color => AppColors.red;

  @override
  double get rate => speedIncrease.clamp(1.01, 2.0);

  @override
  double get pitch => 1.5;

  @override
  bool get ranked => rate == 1.5;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.halfTime,
    ModInfo.daycore,
    ModInfo.doubleTime,
    // AdaptiveSpeed,
    // WindUp,
    // WindDown,
  };
}

/// A mod that hides the approach circles and fades the hit objects
class Hidden extends ModificableMod {
  Hidden([ModConfiguration? configuration])
    : onlyFadeApproachCircles = configuration?.onlyFadeApproachCircles ?? false,
      super(ModInfo.hidden, configuration);

  final bool onlyFadeApproachCircles;

  @override
  String get assetPath => AppMods.hd;

  @override
  String get description =>
      "Play with no approach circles and fading circles/sliders";

  @override
  double get scoreMultiplier => onlyFadeApproachCircles ? 1.02 : 1.04;

  @override
  bool get ranked => !onlyFadeApproachCircles;

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {
    // FadeIn,
    // Cover,
    ModInfo.flashlight,
    ModInfo.traceable,
    // SpinIn,
    // ApproachDiferent,
    // Depth,
  };
}

/// A mod where only approach circles are shown
class Traceable extends Mod {
  Traceable() : super(ModInfo.traceable);

  @override
  String get assetPath => AppMods.tr;

  @override
  String get description =>
      "Play with no approach circles and fading circles/sliders";

  @override
  double get scoreMultiplier => 1.02;

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {
    // FadeIn,
    // Cover,
    ModInfo.hidden,
    // SpinIn,
    // ApproachDiferent,
    // Depth,
  };
}

/// A mod that restricts the view area using
/// a "flashlight" to find the objects
class Flashlight extends ModificableMod {
  Flashlight([ModConfiguration? configuration])
    : followDelay = configuration?.followDelay ?? 120,
      flashlightSize = configuration?.flashlightSize ?? 1.0,
      changeSizeOnCombo = configuration?.changeSizeOnCombo ?? true,
      super(ModInfo.flashlight, configuration);

  final int followDelay;

  final double flashlightSize;

  final bool changeSizeOnCombo;

  @override
  String get assetPath => AppMods.fl;

  @override
  String get description => "Restricted view area";

  @override
  // TODO: Use formula of score multiplier used in osu!lazer
  double get scoreMultiplier => 1.2;

  @override
  Color get color => AppColors.red;

  @override
  bool get ranked =>
      followDelay == 120 && flashlightSize == 1.0 && changeSizeOnCombo;

  @override
  Set<ModInfo> get incompatibleMods => {
    // FadeIn,
    // Cover,
    ModInfo.blinds,
    // Bloom,
  };
}

/// A mod that introduces blinds on the screen,
/// reducing the visible area of the playfield
/// according to health bar
class Blinds extends Mod {
  Blinds() : super(ModInfo.blinds);

  @override
  String get assetPath => AppMods.bl;

  @override
  String get description => "Play with blinds on your screen";

  @override
  double get scoreMultiplier => 1.24;

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {ModInfo.flashlight};
}

/// A mod that makes the player miss if they don't
/// follow a slider precisely
class StrictTracking extends Mod {
  StrictTracking() : super(ModInfo.strictTracking);

  @override
  String get assetPath => AppMods.st;

  @override
  String get description =>
      "Once you start a slider, follow precisely or get a miss";

  @override
  Color get color => AppColors.red;

  @override
  bool get ranked => false;

  @override
  Set<ModInfo> get incompatibleMods => {
    // TargetPractice,
    ModInfo.classic,
  };
}

/// A mod that makes the player fail if their
/// accuracy drops below a certain threshold
class AccuracyChallenge extends ModificableMod {
  AccuracyChallenge([ModConfiguration? configuration])
    : minimumAccuracy = configuration?.minimumAccuracy ?? 90,
      restartOnFail = configuration?.restartOnFail ?? false,
      super(ModInfo.accuracyChallenge, configuration);

  /// The minimum accuracy required to pass the map
  final double minimumAccuracy;

  /// If gameplay should restart when the player fails
  final bool restartOnFail;

  @override
  String get assetPath => AppMods.ac;

  @override
  String get description => "Fail if your accuracy drops too low!";

  @override
  Color get color => AppColors.red;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.easy,
    ModInfo.noFail,
    ModInfo.perfect,
    ModInfo.cinema,
  };
}
