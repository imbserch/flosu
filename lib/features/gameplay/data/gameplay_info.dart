import 'package:flosu/models/beatmap/beatmap_content.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/models/generated/beatmap_metadata.dart';

class GameplayInfo {
  const GameplayInfo({
    this.metadata,
    this.contents,
    this.replay,
    this.mods = const {},
  });

  final BeatmapMetadata? metadata;
  final BeatmapContent? contents;

  final Replay? replay;
  final Set<ConfigurableMod> mods;

  // Flags indicate if the data is ready to start the gameplay
  bool get validForGameplay {
    final containsFullBeatmap = metadata != null && contents != null;

    if (containsFullBeatmap) {
      if (replay != null) return replay!.hash == metadata!.md5;
      return metadata!.md5 == contents!.md5;
    }

    return false;
  }

  GameplayInfo copyWith({
    BeatmapMetadata? metadata,
    BeatmapContent? contents,
    Replay? replay,
    Set<ConfigurableMod>? mods,
    bool clearReplay = false,
    bool clearContents = false,
  }) {
    return GameplayInfo(
      metadata: metadata ?? this.metadata,
      contents: clearContents ? null : (contents ?? this.contents),
      replay: clearReplay ? null : (replay ?? this.replay),
      mods: mods ?? this.mods,
    );
  }

  BeatmapDifficultyMetadata get difficultyWithMods {
    if (metadata == null) return BeatmapDifficultyMetadata();

    var difficulty = metadata!.difficulty;

    for (final mod in mods) {
      difficulty = mod.applyTo(difficulty);
    }

    return difficulty;
  }

  /// Combined score multiplier from all active mods.
  double get modMultiplier =>
      mods.fold<double>(1.0, (t, m) => t * m.scoreMultiplier);

  /// Whether the current mod combination is eligible for leaderboard ranking.
  bool get isRanked => mods.every((m) => m.ranked);

  /// A concatenated string of mod acronyms (e.g. `"HDDTHR"`).
  String get modsName => mods.fold("", (str, mod) => str += mod.mod.acronym);
}
