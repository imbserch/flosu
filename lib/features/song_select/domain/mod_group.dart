import 'dart:ui' show Color;

import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/shared/domain/mod/mod.dart';

class ModGroup {
  ModGroup(this.mods, this.type, this.color);

  final List<Mod> mods;
  final String type;
  final Color color;
}

class ModGroups {
  static ModGroup get difficultyReduction => ModGroup(
    [Easy(), NoFail(), HalfTime(), Daycore()],
    "Difficulty Reduction",
    AppColors.green,
  );

  static ModGroup get difficultyIncrease =>
      ModGroup([HardRock(), SuddenDeath(), Perfect(), DoubleTime(),Nightcore(), Hidden(), Flashlight()], "Difficulty Increase", AppColors.red);

  static ModGroup get automation =>
      ModGroup([], "Automation", AppColors.lightBlue);

  static ModGroup get conversion =>
      ModGroup([], "Conversion", AppColors.purple);

  static ModGroup get fun => ModGroup([], "Fun", AppColors.pink);

  static List<ModGroup> get all => [
    difficultyReduction,
    difficultyIncrease,
    automation,
    conversion,
    fun,
  ];
}
