import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/replay/replay.dart';

/// Holds the configuration for an upcoming or ongoing play session.
///
/// This is the state managed by [GameplayService], representing what was
/// selected before entering gameplay. It is distinct from [ScoreState],
/// which tracks live scoring during play.
class GameplayData {
  GameplayData({this.beatmap, this.replay, this.mods = const {}});

  /// The beatmap selected for play.
  final Beatmap? beatmap;

  /// An optional replay file loaded for spectating.
  final Replay? replay;

  /// The set of active mods for this session.
  final Set<ConfigurableMod> mods;

  GameplayData copyWith({
    Beatmap? beatmap,
    Replay? replay,
    Set<ConfigurableMod>? mods,
  }) => GameplayData(
    beatmap: beatmap ?? this.beatmap,
    replay: replay,
    mods: mods ?? this.mods,
  );

  /// Returns the beatmap difficulty, modified by mods.
  BeatmapDifficulty? get difficultyWithMods {
    if (beatmap == null) return null;

    var difficulty = beatmap!.difficulty;

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
  String get modsName => mods.fold("", (str, mod) => str += mod.acronym);
}
