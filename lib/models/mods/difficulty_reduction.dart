part of "base.dart";

class Easy extends ConfigurableMod {
  @override
  String get name => "Easy";

  @override
  String get acronym => "EZ";

  @override
  String get description =>
      "Larger circles, more forgiving HP drain,"
      "less accuracy required, and three lives!";

  @override
  double get scoreMultiplier => 0.3;

  @override
  Color get color => AppColors.green;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    HardRock(),
    AccuracyChallenge(),
    DifficultyAdjust(),
  };
}

class NoFail extends ConfigurableMod {
  @override
  String get name => "No Fail";

  @override
  String get acronym => "NF";

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

class HalfTime extends ConfigurableMod {
  @override
  String get name => "Half Time";

  @override
  String get acronym => "HT";

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
}

class Daycore extends ConfigurableMod {
  @override
  String get name => "Daycore";

  @override
  String get acronym => "DC";

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
}
