part of "base.dart";

class Autoplay extends ConfigurableMod {
  @override
  Mod get mod => Mod.autoplay;

  @override
  String get assetPath => AppMods.at;

  @override
  String get description => "Watch a perfect automated play through the song";

  @override
  Color get color => AppColors.lightBlue;

  @override
  bool get ranked => false;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    Cinema(),
    Relax(),
    // AutoPilot(),
    // SpunOut(),
    // Alternate(),
    // SingleTap(),
    // Magnetised(),
    // Repel(),
    // AdaptiveSpeed(),
    // TouchDevice(),
  };
}

class Cinema extends ConfigurableMod {
  @override
  Mod get mod => Mod.cinema;

  @override
  String get assetPath => AppMods.cn;

  @override
  String get description => "Watch the video without visual distractions";

  @override
  Color get color => AppColors.lightBlue;

  @override
  bool get ranked => false;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    NoFail(),
    SuddenDeath(),
    Perfect(),
    AccuracyChallenge(),
    Autoplay(),
    Relax(),
    // AutoPilot(),
    // SpunOut(),
    // Alternate(),
    // SingleTap(),
    // Magnetised(),
    // Repel(),
    // AdaptiveSpeed(),
    // TouchDevice(),
  };
}

class Relax extends ConfigurableMod {
  @override
  Mod get mod => Mod.relax;

  @override
  String get assetPath => AppMods.rx;

  @override
  String get description =>
      "You don't need to click. "
      "Give your clicking/tapping fingers a break from the heat of things";

  @override
  Color get color => AppColors.lightBlue;

  @override
  double get scoreMultiplier => 0.1;

  @override
  bool get ranked => false;

  @override
  Set<ConfigurableMod> get incompatibleMods => {
    Autoplay(),
    Cinema(),
    // AutoPilot(),
    // Alternate(),
    // SingleTap(),
    // Magnetised(),
  };
}
