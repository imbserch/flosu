part of "base.dart";

class HardRock extends ConfigurableMod {
  @override
  String get name => "Hard Rock";

  @override
  String get acronym => "HR";

  @override
  String get assetPath => AppMods.hr;

  @override
  String get description => "Everything just got a bit harder...";

  @override
  double get scoreMultiplier => 1.06;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    Easy(),
    DifficultyAdjust(),
    // Mirror(),
  };

  @override
  BeatmapDifficultyMetadata applyTo(BeatmapDifficultyMetadata difficulty) {
    final newDifficulty = BeatmapDifficultyMetadata()
      ..cs = (difficulty.cs * 1.3).clamp(0, 10)
      ..ar = (difficulty.ar * 1.4).clamp(0, 10)
      ..od = (difficulty.od * 1.4).clamp(0, 10)
      ..hp = (difficulty.hp * 1.4).clamp(0, 10)
      ..sliderMultiplier = difficulty.sliderMultiplier
      ..sliderTickRate = difficulty.sliderTickRate;

    return newDifficulty;
  }
}

class SuddenDeath extends ConfigurableMod {
  @override
  String get name => "Sudden Death";

  @override
  String get acronym => "SD";

  @override
  String get assetPath => AppMods.sd;

  @override
  String get description => "Miss and fail";

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    NoFail(),
    Perfect(),
    Cinema(),
    // TargetPractice(),
  };
}

class Perfect extends ConfigurableMod {
  @override
  String get name => "Perfect";

  @override
  String get acronym => "PF";

  @override
  String get assetPath => AppMods.pf;

  @override
  String get description => "SS or quit";

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    NoFail(),
    SuddenDeath(),
    AccuracyChallenge(),
    Cinema(),
  };
}

class DoubleTime extends ConfigurableMod {
  @override
  String get name => "Double Time";

  @override
  String get acronym => "DT";

  @override
  String get assetPath => AppMods.dt;

  @override
  String get description => "Zoooooooooom...";

  @override
  double get scoreMultiplier => 1.1;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    HalfTime(),
    Daycore(),
    Nightcore(),
    // AdaptiveSpeed(),
    // WindUp(),
    // WindDown(),
  };

  @override
  void activate(ProviderContainer ref) {
    // Set the initial speed to 1.5x
    ref.read(audioProvider.notifier).setRate(1.5);
    super.activate(ref);
  }

  @override
  void deactivate(ProviderContainer ref) {
    // Restore the default speed to 1.0x
    ref.read(audioProvider.notifier).setRate(1.0);
    super.deactivate(ref);
  }
}

class Nightcore extends ConfigurableMod {
  @override
  String get name => "Nightcore";

  @override
  String get acronym => "NC";

  @override
  String get assetPath => AppMods.nc;

  @override
  String get description => "Uguuuuuuuu...";

  @override
  double get scoreMultiplier => 1.1;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    HalfTime(),
    Daycore(),
    DoubleTime(),
    // AdaptiveSpeed(),
    // WindUp(),
    // WindDown(),
  };

  @override
  void activate(ProviderContainer ref) {
    // Set the initial speed to 1.5x
    ref.read(audioProvider.notifier).setRate(1.5);
    ref.read(audioProvider.notifier).setPitch(1.05);
    super.activate(ref);
  }

  @override
  void deactivate(ProviderContainer ref) {
    // Restore the default speed to 1.0x
    ref.read(audioProvider.notifier).setRate(1.0);
    ref.read(audioProvider.notifier).setPitch(1.0);
    super.deactivate(ref);
  }
}

class Hidden extends ConfigurableMod {
  @override
  String get name => "Hidden";

  @override
  String get acronym => "HD";

  @override
  String get assetPath => AppMods.hd;

  @override
  String get description =>
      "Play with no approach circles and fading circles/sliders";

  @override
  double get scoreMultiplier => 1.06;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    // FadeIn(),
    //Cover(),
    Flashlight(),
    // SpinIn(),
    // Traceable(),
    // ApproachDiferent(),
    //Depth(),
  };
}

class Flashlight extends ConfigurableMod {
  @override
  String get name => "Flashlight";

  @override
  String get acronym => "FL";

  @override
  String get assetPath => AppMods.fl;

  @override
  String get description => "Restricted view area";

  @override
  double get scoreMultiplier => 1.12;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    // FadeIn(),
    // Cover(),
    Blinds(),
    // Bloom(),
  };
}

class Blinds extends ConfigurableMod {
  @override
  String get name => "Blinds";

  @override
  String get acronym => "BL";

  @override
  String get assetPath => AppMods.bl;

  @override
  String get description => "Play with blinds on your screen";

  @override
  double get scoreMultiplier => 1.12;

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {Flashlight()};
}

class StrictTracking extends ConfigurableMod {
  @override
  String get name => "Strict Tracking";

  @override
  String get acronym => "ST";

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
  Set<ConfigurableMod> get incompatibleMods => {
    // TargetPractice(),
    Classic(),
  };
}

class AccuracyChallenge extends ConfigurableMod {
  @override
  String get name => "Accuracy Challenge";

  @override
  String get acronym => "AC";

  @override
  String get assetPath => AppMods.ac;

  @override
  String get description => "Fail if your accuracy drops too low!";

  @override
  Color get color => AppColors.red;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    Easy(),
    NoFail(),
    Perfect(),
    Cinema(),
  };
}
