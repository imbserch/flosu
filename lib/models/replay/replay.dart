import 'package:flosu/models/replay/replay_frame.dart';
import 'package:flosu/models/mods/base.dart';

/// A parsed `.osr` replay file from the osu! stable client.
///
/// Contains the full sequence of [ReplayFrame]s recorded during a play session,
/// plus the [ReplayHitStats] summary visible on the results screen.
class Replay {
  const Replay(
    this.version,
    this.hash,
    this.playerName,
    this.hitStats,
    this.mods,
    this.lifeGraph,
    this.timestamp,
    this.frames,
  );

  /// osu! game mode version encoded in the replay file.
  final int version;

  /// MD5 hash of the beatmap this replay belongs to.
  final String hash;

  /// Username of the player who recorded this replay.
  final String playerName;

  /// Summary of hit counts, score, and combo from the replay.
  final ReplayHitStats hitStats;

  /// Mods active when the replay was recorded.
  final Set<ConfigurableMod> mods;

  /// Raw life-graph string encoding health at each point in time.
  final String lifeGraph;

  /// Unix timestamp (in Windows FILETIME ticks) when the replay was recorded.
  final int timestamp;

  /// Chronological list of all recorded input frames.
  final List<ReplayFrame> frames;

  @override
  String toString() =>
      "Replay of $playerName at ${DateTime(0, 12, 21, 21, 30).add(Duration(milliseconds: timestamp ~/ 10000))} "
      "using mods ${mods.join(", ")} and the following stats: ${hitStats.toString()}";
}

/// Summary statistics embedded in a [Replay] file.
///
/// These values correspond to the counts and score shown on the results screen
/// of the osu! stable client.
class ReplayHitStats {
  ReplayHitStats(
    this.greats,
    this.oks,
    this.mehs,
    this.gekis,
    this.katus,
    this.misses,
    this.score,
    this.maxCombo,
    this.perfect,
  );

  /// Number of 300-point hits.
  final int greats;

  /// Number of 100-point hits.
  final int oks;

  /// Number of 50-point hits.
  final int mehs;

  /// Number of Elite Beat! (rainbow 300) hits.
  final int gekis;

  /// Number of Beat! (200) hits.
  final int katus;

  /// Number of missed objects.
  final int misses;

  /// Total score achieved.
  final int score;

  /// Highest combo reached during the play.
  final int maxCombo;

  /// Whether a full combo was achieved.
  final bool perfect;

  @override
  String toString() =>
      "Obtained $score score with $greats greats, $oks oks, $mehs mehs, "
      "$gekis gekis, $katus katus, and $misses misses, "
      "and $maxCombo of max combo (perfect? $perfect)";
}
