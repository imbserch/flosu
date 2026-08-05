import 'package:collection/collection.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/shared/domain/mod/mod.dart';

class ModConverter {
  static Set<Mod> fromJson(Map<String, dynamic> json) {
    try {
      //Assuming the lazer don't have Classic behavior enabled by default
      final Set<Mod> finalMods = {};

      final rawModList = json['mods'] as List<dynamic>?;
      if (rawModList == null) return finalMods;

      final rawModContents = rawModList
          .map((r) => r as Map<String, dynamic>)
          .toList();

      for (final rawMod in rawModContents) {
        final rawAcronym = rawMod["acronym"] as String?;
        if (rawAcronym == null) continue;

        final modData = ModInfo.values.firstWhereOrNull(
          (m) => m.acronym == rawAcronym,
        );

        if (modData == null) continue;

        final Mod? mod = switch (modData) {
          .noFail => NoFail(),
          .easy => Easy(),
          // .touch => TouchDevice(),
          .hidden => Hidden(),
          .hardRock => HardRock(),
          .suddenDeath => SuddenDeath(),
          .doubleTime => DoubleTime(),
          .relax => Relax(),
          .halfTime => HalfTime(),
          .nightcore => Nightcore(),
          .flashlight => Flashlight(),
          .autoplay => Autoplay(),
          // .spunOut => SpunOut(),
          // .autopilot => Autopilot(),
          .perfect => Perfect(),
          .cinema => Cinema(),
          .daycore => Daycore(),
          .traceable => Traceable(),
          .blinds => Blinds(),
          .strictTracking => StrictTracking(),
          .accuracyChallenge => AccuracyChallenge(),
          .difficultyAdjust => DifficultyAdjust(),
          // .noScope => NoScope(),
          .classic => Classic(),
          _ => null,
        };

        if (mod != null) finalMods.add(mod);
      }

      return finalMods;
    } catch (e) {
      return {};
    }
  }

  static Set<Mod> fromBitFlag(int bit) {
    //Assuming the stable replays use Classic behavior
    final Set<Mod> foundMods = {Classic()};

    final stableMods = ModInfo.values.where((mod) => mod.value != null);

    for (final mod in stableMods) {
      final value = 1 << mod.value!;

      if ((value & bit) == 0) continue;

      final Mod? selectedMod = switch (mod) {
        .noFail => NoFail(),
        .easy => Easy(),
        // .touch => TouchDevice(),
        .hidden => Hidden(),
        .hardRock => HardRock(),
        .suddenDeath => SuddenDeath(),
        .doubleTime => DoubleTime(),
        .relax => Relax(),
        .halfTime => HalfTime(),
        .nightcore => Nightcore(),
        .flashlight => Flashlight(),
        .autoplay => Autoplay(),
        // .spunOut => SpunOut(),
        // .autopilot => AutoPilot(),
        .perfect => Perfect(),
        .cinema => Cinema(),
        _ => null,
      };

      if (selectedMod != null) foundMods.add(selectedMod);
    }

    return foundMods;
  }

  static Set<ModInfo> get inOrder => {
    .easy,
    .noFail,
    .halfTime,
    .daycore,
    //TouchDevice,
    .hardRock,
    .suddenDeath,
    .perfect,
    .doubleTime,
    .nightcore,
    .hidden,
    .traceable,
    .flashlight,
    .blinds,
    .strictTracking,
    .accuracyChallenge,
    .autoplay,
    .cinema,
    .relax,
    // AutoPilot,
    // SpunOut,
    .difficultyAdjust,
    // Alternate,
    // SingleTap,
    .noScope,
    .classic,
    // Magnetised,
    // Repel,
    // FadeIn,
    // Cover,
    // AdaptiveSpeed,
    // WindUp,
    // WindDown,
  };
}
