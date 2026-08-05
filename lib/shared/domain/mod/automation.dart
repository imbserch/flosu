part of "mod.dart";

class Autoplay extends Mod {
  Autoplay() : super(ModInfo.autoplay);

  @override
  String get assetPath => AppMods.at;

  @override
  String get description => "Watch a perfect automated play through the song";

  @override
  Color get color => AppColors.lightBlue;

  @override
  bool get ranked => false;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.cinema,
    ModInfo.relax,
    // AutoPilot,
    // SpunOut,
    // Alternate,
    // SingleTap,
    // Magnetised,
    // Repel,
    // AdaptiveSpeed,
    // TouchDevice,
  };
}

class Cinema extends Mod {
  Cinema() : super(ModInfo.cinema);

  @override
  String get assetPath => AppMods.cn;

  @override
  String get description => "Watch the video without visual distractions";

  @override
  Color get color => AppColors.lightBlue;

  @override
  bool get ranked => false;

  @override
  Set<ModInfo> get incompatibleMods => {
    ModInfo.noFail,
    ModInfo.suddenDeath,
    ModInfo.perfect,
    ModInfo.accuracyChallenge,
    ModInfo.autoplay,
    ModInfo.relax,
    // AutoPilot,
    // SpunOut,
    // Alternate,
    // SingleTap,
    // Magnetised,
    // Repel,
    // AdaptiveSpeed,
    // TouchDevice,
  };
}

class Relax extends Mod {
  Relax() : super(ModInfo.relax);

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
  Set<ModInfo> get incompatibleMods => {
    ModInfo.autoplay,
    ModInfo.cinema,
    // AutoPilot,
    // Alternate,
    // SingleTap,
    // Magnetised,
  };
}
