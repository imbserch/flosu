part of "base.dart";

class Easy extends ConfigurableMod {
  @override
  String get name => "Easy";

  @override
  String get acronym => "EZ";

  @override
  String get assetPath => AppMods.ez;

  @override
  String get description =>
      "Larger circles, more forgiving HP drain,"
      "less accuracy required, and three lives!";

  @override
  // Osu!lazer recently updated this value
  double get scoreMultiplier => 0.5;

  @override
  Color get color => AppColors.green;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    HardRock(),
    AccuracyChallenge(),
    DifficultyAdjust(),
  };

  @override
  BeatmapDifficultyMetadata applyTo(BeatmapDifficultyMetadata difficulty) {
    final newDifficulty = BeatmapDifficultyMetadata()
      ..cs = difficulty.cs / 2
      ..ar = difficulty.ar / 2
      ..od = difficulty.od / 2
      ..hp = difficulty.hp / 2
      ..sliderMultiplier = difficulty.sliderMultiplier
      ..sliderTickRate = difficulty.sliderTickRate;

    return newDifficulty;
  }
}

class NoFail extends ConfigurableMod {
  @override
  String get name => "No Fail";

  @override
  String get acronym => "NF";

  @override
  String get assetPath => AppMods.nf;

  @override
  String get description => "You can't fail, no matter what";

  @override
  double get scoreMultiplier => 0.5;

  @override
  Color get color => AppColors.green;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    AccuracyChallenge(),
    Perfect(),
    SuddenDeath(),
    Cinema(),
  };
}

// Note: This mod will not sound like the original Osu! HT because of SoLoud implementation
class HalfTime extends ConfigurableMod {
  @override
  String get name => "Half Time";

  @override
  String get acronym => "HT";

  @override
  String get assetPath => AppMods.ht;

  @override
  String get description => "Less zoom...";

  @override
  double get scoreMultiplier => 0.3;

  @override
  Color get color => AppColors.green;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    Daycore(),
    DoubleTime(),
    Nightcore(),
    // AdaptiveSpeed(),
    // WindUp(),
    // WindDown(),
  };

  @override
  void activate(ProviderContainer ref) {
    // Set the initial speed to 0.75x
    ref.read(audioProvider.notifier).setRate(0.75);
    super.activate(ref);
  }

  @override
  void deactivate(ProviderContainer ref) {
    // Restore the default speed to 1.0x
    ref.read(audioProvider.notifier).setRate(1.0);
    super.deactivate(ref);
  }
}

// Note: This mod will sound exactly like Osu! DC because of SoLoud pitch shifting
class Daycore extends ConfigurableMod {
  @override
  String get name => "Daycore";

  @override
  String get acronym => "DC";

  @override
  String get assetPath => AppMods.dc;

  @override
  String get description => "Whoaaaaa...";

  @override
  double get scoreMultiplier => 0.3;

  @override
  Color get color => AppColors.green;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    HalfTime(),
    DoubleTime(),
    Nightcore(),
    // AdaptiveSpeed(),
    // WindUp(),
    // WindDown(),
  };

  @override
  void activate(ProviderContainer ref) {
    // Set the initial speed to 0.75x
    ref.read(audioProvider.notifier).setRate(0.75);
    ref.read(audioProvider.notifier).setPitch(0.975);
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
