import 'package:isar_community/isar.dart';

part 'beatmap_metadata.g.dart';

@collection
class BeatmapMetadata {
  Id id = Isar.autoIncrement;

  // Beatmap MD5 hash, used to identify beatmaps
  @Index(unique: true)
  late String md5;

  // Beatmap file path
  @Index(unique: true)
  late String filePath;

  BeatmapInfoMetadata info = BeatmapInfoMetadata();
  BeatmapGeneralMetadata general = BeatmapGeneralMetadata();

  BeatmapDifficultyMetadata difficulty = BeatmapDifficultyMetadata();
  BeatmapHitObjectsMetadata hitObjects = BeatmapHitObjectsMetadata();
}

@embedded
class BeatmapGeneralMetadata {
  // Beatmap IDs
  int? beatmapSetId;
  int? beatmapId;

  // Other file paths
  String? backgroundPath;
  String? audioPath;

  int previewTime = 0;
}

@embedded
class BeatmapInfoMetadata {
  // Beatmap metadata
  String title = "";
  String artist = "";
  String creator = "";
  String version = "";
  String source = "";
  String tags = "";
}

@embedded
class BeatmapDifficultyMetadata {
  // Difficulty settings
  double cs = 5;
  double ar = 5;
  double od = 5;
  double hp = 5;
  double sliderMultiplier = 1;
  double sliderTickRate = 1;

  /// Time in milliseconds between when an object appears and when it must be hit.
  ///
  /// Custom formula (differs slightly from osu! stable):
  /// - AR ≤ 5 → `1200 + 120 * (5 - AR)`
  /// - AR > 5 → `1200 - 150 * (AR - 5)`
  @ignore
  double get preempt {
    if (ar <= 5) return 1200 + 120 * (5 - ar);
    return 1200 - 150 * (ar - 5);
  }

  /// Time in milliseconds over which an object fades in to full opacity.
  ///
  /// Equal to one third of [preempt].
  @ignore
  double get preemptFullOp => preempt / 3;

  /// Radius of hit circles in playfield pixels.
  @ignore
  double get circleRadius => (54.4 - (4.48 * cs)) * 1.00041;

  /// Per-frame health drain multiplier based on HP.
  @ignore
  double get healthDrain => hp / 100;

  /// Half-width of the 300-point (great) timing window, in milliseconds.
  @ignore
  double get hit300 => 80 - 6 * od;

  /// Half-width of the 100-point (ok) timing window, in milliseconds.
  @ignore
  double get hit100 => 140 - 8 * od;

  /// Half-width of the 50-point (meh) timing window, in milliseconds.
  ///
  /// Hits outside this window are registered as misses.
  @ignore
  double get hit50 => 200 - 10 * od;
}

@embedded
class BeatmapHitObjectsMetadata {
  // Number of objects
  int circles = 0;
  int sliders = 0;
  int spinners = 0;

  @ignore
  int get total => circles + sliders + spinners;
}
