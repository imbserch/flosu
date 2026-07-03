import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/assets.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/core/extensions/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part "difficulty_increase.dart";
part "difficulty_reduction.dart";
part "automation.dart";
part "conversion.dart";
part "fun.dart";

/// Represents a gameplay modifier (mod) that alters game parameters or rules.
///
/// Subclasses define specific modifications to gameplay mechanics, speed, difficulty,
/// scoring multiplier, and visual rendering.
sealed class ConfigurableMod {
  static Set<ConfigurableMod> fromLazerPayload(Map<String, dynamic> json) {
    try {
      //Assuming the lazer don't have Classic behavior enabled by default
      final Set<ConfigurableMod> finalMods = {};

      final rawModList = json['mods'] as List<dynamic>;
      final rawModContents = rawModList
          .map((r) => r as Map<String, dynamic>)
          .toList();

      for (final rawMod in rawModContents) {
        final acronym = rawMod["acronym"] as String?;
        if (acronym == null) continue;

        final ConfigurableMod mod = switch (acronym.log()) {
          "CL" => Classic(),
          "EZ" => Easy(),
          "HD" => Hidden(),
          "HR" => HardRock(),
          "DT" => DoubleTime(),
          "RX" => Relax(),
          String default_ => Unimplemented(default_),
        };

        finalMods.add(mod);
      }

      return finalMods;
    } catch (e) {
      e.log();
      return {};
    }
  }

  static Set<ConfigurableMod> fromStableBit(int bit) {
    //Search for mod values and reconstruct mod configurations
    final List<Mod> foundMods = [];

    for (int i = 0; i < 32; i++) {
      final modValue = 1 << i;

      if ((modValue & bit) != 0) {
        final selectedMod = Mod.values.firstWhereOrNull((m) => m.v == modValue);
        if (selectedMod != null) foundMods.add(selectedMod);
      }
    }

    //Assuming the stable replays use Classic behavior
    final Set<ConfigurableMod> finalMods = {Classic()};

    for (final recoveredMod in foundMods) {
      final ConfigurableMod mod = switch (recoveredMod) {
        /* Mod.noFail => Unimplemented(), */
        Mod.easy => Easy(),
        /* Mod.touch => Unimplemented(), */
        Mod.hidden => Hidden(),
        /* Mod.hardRock => Unimplemented(),
        Mod.suddenDeath => Unimplemented(),
        Mod.doubleTime => Unimplemented(),
        Mod.relax => Unimplemented(),
        Mod.halfTime => Unimplemented(),
        Mod.nightcore => Unimplemented(),
        Mod.flashlight => Unimplemented(),
        Mod.autoplay => Unimplemented(),
        Mod.spunOut => Unimplemented(),
        Mod.autopilot => Unimplemented(),
        Mod.perfect => Unimplemented(),
        Mod.cinema => Unimplemented(), */
        Mod default_ => Unimplemented(default_.name),
      };

      finalMods.add(mod);
    }

    return finalMods;
  }

  static Map<String, Set<ConfigurableMod>> get diffSections => {
    "Difficulty Reduction": {Easy(), NoFail(), HalfTime(), Daycore()},
    "Difficulty Increase": {
      HardRock(),
      SuddenDeath(),
      Perfect(),
      DoubleTime(),
      Nightcore(),
      Hidden(),
      Flashlight(),
      Blinds(),
      StrictTracking(),
      AccuracyChallenge(),
    },
    "Automation": {Autoplay(), Cinema(), Relax()},
    "Conversion": {Classic(), DifficultyAdjust()},
    "Fun": {NoScope()},
  };

  static Set<ConfigurableMod> get allOrdered {
    final Set<ConfigurableMod> all = {};

    for (final values in diffSections.values) {
      all.addAll(values);
    }

    return all;
  }

  String get name;
  String get acronym;

  String get description;

  String get assetPath;

  double get scoreMultiplier => 1.0;

  bool get ranked => true;

  Color get color;

  Set<ConfigurableMod> get incompatibleMods => {};

  BeatmapDifficulty applyTo(BeatmapDifficulty difficulty) => difficulty;

  void activate(ProviderContainer ref) {
    // TODO: USE LEGACY LOG FOR NOW
    "Activating $name mod".log();
  }

  void deactivate(ProviderContainer ref) {
    // TODO: USE LEGACY LOG FOR NOW
    "Deactivating $name mod".log();
  }
}

//Keep here because this is for non added mods
/// A fallback modifier representing a mod that is unrecognized or not yet supported.
class Unimplemented extends ConfigurableMod {
  Unimplemented(this.data);

  final dynamic data;

  @override
  String get acronym => "??";

  @override
  String get assetPath => AppMods.at;

  @override
  String get name => "Unimplemented";

  @override
  String get description => "Mod with invalid or unimplemented data: $data";

  @override
  Color get color => Colors.grey;

  @override
  bool get ranked => false;
}
