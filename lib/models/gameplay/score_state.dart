import 'package:collection/collection.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/models/gameplay/hit_data.dart';

/// Immutable snapshot of the live gameplay state during a play session.
///
/// All mutable gameplay counters (score, combo, health, hits) are stored here.
/// The [GameplayController] produces new [ScoreState] instances on every
/// relevant event, which are then broadcast to the UI via [ValueNotifier].
class ScoreState {
  const ScoreState({
    this.score = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.health = 200,
    this.greats = 0,
    this.oks = 0,
    this.mehs = 0,
    this.misses = 0,
    this.hits = const [],
  });

  /// The accumulated score based on hit values and combo multiplier.
  final int score;

  /// The current consecutive-hit streak (resets on miss).
  final int combo;

  /// The highest combo streak reached during this play.
  final int maxCombo;

  /// The current health value. Ranges from 0 (fail) to 200 (full).
  final double health;

  /// Number of 300-point hits (great).
  final int greats;

  /// Number of 100-point hits (ok).
  final int oks;

  /// Number of 50-point hits (meh).
  final int mehs;

  /// Number of missed objects.
  final int misses;

  /// Chronological list of all evaluated hits, used for the hit error meter.
  final List<HitData> hits;

  /// Total evaluated objects (hits + misses). Used as denominator for accuracy.
  int get totalObjects => greats + oks + mehs + misses;

  /// Accuracy as a value from 0.0 to 1.0.
  ///
  /// Uses the osu! standard formula:
  /// `accuracy = (300*greats + 100*oks + 50*mehs) / (300 * totalObjects)`
  double get accuracy {
    if (totalObjects == 0) return 1.0;
    final numerator = 300 * greats + 100 * oks + 50 * mehs;
    return numerator / (300 * totalObjects);
  }

  /// Formatted accuracy string (e.g. "98.42%").
  String get accuracyDisplay =>
      '${(accuracy * 100).clamp(0, 100).toStringAsFixed(2)}%';

  /// The average hit timing error (negative = early, positive = late), in ms.
  ///
  /// Misses are excluded from this calculation.
  double get avgHitTime {
    final nonMisses = hits.where((h) => h.result != HitResult.miss);
    if (nonMisses.isEmpty) return 0;
    return -nonMisses.map((h) => h.timeLeft).sum / nonMisses.length;
  }

  /// Whether the player is still alive (health > 0).
  bool get isAlive => health > 0;

  /// Creates a copy of this state with updated fields.
  ScoreState copyWith({
    int? score,
    int? combo,
    int? maxCombo,
    double? health,
    int? greats,
    int? oks,
    int? mehs,
    int? misses,
    List<HitData>? hits,
  }) => ScoreState(
    score: score ?? this.score,
    combo: combo ?? this.combo,
    maxCombo: maxCombo ?? this.maxCombo,
    health: health ?? this.health,
    greats: greats ?? this.greats,
    oks: oks ?? this.oks,
    mehs: mehs ?? this.mehs,
    misses: misses ?? this.misses,
    hits: hits ?? this.hits,
  );
}
