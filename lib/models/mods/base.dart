import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/storage/beatmap_metadata.dart';
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
        final rawAcronym = rawMod["acronym"] as String?;
        if (rawAcronym == null) continue;

        final modData = Mod.values.firstWhereOrNull(
          (m) => m.acronym == rawAcronym,
        );

        final ConfigurableMod mod = switch (modData) {
          Mod.noFail => NoFail(),
          Mod.easy => Easy(),
          // Mod.touch => TouchDevice(),
          Mod.hidden => Hidden(),
          Mod.hardRock => HardRock(),
          Mod.suddenDeath => SuddenDeath(),
          Mod.doubleTime => DoubleTime(),
          Mod.relax => Relax(),
          Mod.halfTime => HalfTime(),
          Mod.nightcore => Nightcore(),
          Mod.flashlight => Flashlight(),
          Mod.autoplay => Autoplay(),
          // Mod.spunOut => SpunOut(),
          // Mod.autopilot => Autopilot(),
          Mod.perfect => Perfect(),
          Mod.cinema => Cinema(),
          Mod.daycore => Daycore(),
          Mod.blinds => Blinds(),
          Mod.strictTracking => StrictTracking(),
          Mod.accuracyChallenge => AccuracyChallenge(),
          Mod.difficultyAdjust => DifficultyAdjust(),
          Mod.noScope => NoScope(),
          Mod.classic => Classic(),
          _ => Unimplemented(modData?.acronym ?? Mod.unimplemented.acronym),
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
    //Assuming the stable replays use Classic behavior
    final Set<ConfigurableMod> foundMods = {Classic()};

    for (int i = 0; i < Mod.values.length; i++) {
      final value = 1 << i;
      final bit = Mod.values[i].v;
      // Is a osu!lazer mod
      if (bit == null) continue;

      // Is not in the provided bit
      if ((value & bit) == 0) continue;

      final selectedMod = Mod.values.firstWhereOrNull((m) => m.v == value);
      if (selectedMod == null) continue;

      final ConfigurableMod? mod = switch (selectedMod) {
        // Skip mods that aren't implemented in osu!stable
        var _ when selectedMod.v == null => null,
        Mod.noFail => NoFail(),
        Mod.easy => Easy(),
        // Mod.touch => TouchDevice(),
        Mod.hidden => Hidden(),
        Mod.hardRock => HardRock(),
        Mod.suddenDeath => SuddenDeath(),
        Mod.doubleTime => DoubleTime(),
        Mod.relax => Relax(),
        Mod.halfTime => HalfTime(),
        Mod.nightcore => Nightcore(),
        Mod.flashlight => Flashlight(),
        Mod.autoplay => Autoplay(),
        // Mod.spunOut => SpunOut(),
        // Mod.autopilot => Autopilot(),
        Mod.perfect => Perfect(),
        Mod.cinema => Cinema(),
        _ => Unimplemented(selectedMod.acronym),
      };

      if (mod != null) foundMods.add(mod);
    }

    return foundMods;
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

  Mod get mod;

  String get description;

  String get assetPath;

  double get scoreMultiplier => 1.0;

  bool get ranked => true;

  Color get color;

  Set<ConfigurableMod> get incompatibleMods => {};

  BeatmapDifficultyMetadata applyTo(BeatmapDifficultyMetadata difficulty) =>
      difficulty;

  void activate(ProviderContainer ref) {
    "Activating ${mod.name} mod".log();
  }

  void deactivate(ProviderContainer ref) {
    "Deactivating ${mod.name} mod".log();
  }
}

//Keep here because this is for non added mods
/// A fallback modifier representing a mod that is unrecognized or not yet supported.
class Unimplemented extends ConfigurableMod {
  Unimplemented(this.data);

  final dynamic data;

  @override
  Mod get mod => Mod.unimplemented;

  @override
  String get assetPath => AppMods.at;

  @override
  String get description => "Mod with invalid or unimplemented data: $data";

  @override
  Color get color => Colors.grey;

  @override
  bool get ranked => false;
}
