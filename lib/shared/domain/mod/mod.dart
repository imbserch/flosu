import 'dart:ui' show Color;

import 'package:flosu/core/assets.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/shared/domain/mod/mod_configuration.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';

part "difficulty_reduction.dart";
part "difficulty_increase.dart";
part "conversion.dart";
part "automation.dart";
// part "fun.dart";

sealed class Mod {
  Mod(this.info);

  final ModInfo info;

  /// The modification's effect summary.
  String get description;

  /// The modification's score multiplier.
  double get scoreMultiplier => 1.0;

  /// The path of mod images.
  String get assetPath;

  /// The modification's ranked status.
  bool get ranked => true;

  /// The modification's color.
  Color get color;

  /// The modification's incompatible mods.
  Set<ModInfo> get incompatibleMods => {};

  /// Applies the modification to a beatmap difficulty.
  Difficulty applyTo(Difficulty difficulty) => difficulty;
}

sealed class ModificableMod extends Mod {
  ModificableMod(super.info, [this.configuration]);
  final ModConfiguration? configuration;
}

sealed class AudioModificableMod extends ModificableMod {
  AudioModificableMod(super.info, super.configuration);

  double get rate;

  double get pitch;
}
