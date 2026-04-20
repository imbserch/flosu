import 'package:flosu/models/replay/replay_frame.dart';
import 'package:flosu/models/mods/base.dart';

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
  final int version;
  final String hash;
  final String playerName;

  final ReplayHitStats hitStats;

  final Set<ConfigurableMod> mods;

  final String lifeGraph;
  final int timestamp;

  final List<ReplayFrame> frames;

  @override
  String toString() =>
      "Replay of $playerName at ${DateTime(0, 12, 21, 21, 30).add(Duration(milliseconds: timestamp ~/ 10000))} "
      "using mods ${mods.join(", ")} and the following stats: ${hitStats.toString()}";
}

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
  final int greats;
  final int oks;
  final int mehs;

  final int gekis;
  final int katus;

  final int misses;
  final int score;

  final int maxCombo;
  final bool perfect;

  @override
  String toString() =>
      "Obtained $score score with $greats greats, $oks oks, $mehs mehs, "
      "$gekis gekis, $katus katus, and $misses misses, "
      "and $maxCombo of max combo (perfect? $perfect)";
}
