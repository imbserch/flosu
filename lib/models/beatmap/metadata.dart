// ignore_for_file: non_constant_identifier_names

part of "beatmap.dart";

/// General metadata for a beatmap, parsed from the `[Metadata]` and
/// `[General]` sections of a `.osu` file.
class BeatmapInfo {
  BeatmapInfo.fromMap(Map<String, dynamic> map)
    : title = map["Title"],
      artist = map["Artist"],
      creator = map["Creator"],
      version = map["Version"],
      source = map["Source"] ?? "",
      tags = map["Tags"] ?? "";

  const BeatmapInfo.empty()
    : title = "",
      artist = "",
      creator = "",
      version = "",
      source = "",
      tags = "";

  /// Song title (romanised / ASCII).
  final String title;

  /// Song artist (romanised / ASCII).
  final String artist;

  /// Username of the beatmap creator.
  final String creator;

  /// Difficulty name (e.g. "Easy", "Hard", "Insane").
  final String version;

  /// Original media source (optional).
  final String source;

  /// Space-separated list of search tags (optional).
  final String tags;
}

/// Difficulty settings parsed from the `[Difficulty]` section of a `.osu` file.
///
/// All derived getters (preempt, hit windows, etc.) follow the osu! standard
/// formulas, using slightly adjusted constants for this implementation.
class BeatmapDifficulty {
  BeatmapDifficulty.fromMap(Map<String, dynamic> map)
    : this._(
        HP: double.parse(map["HPDrainRate"] ?? "5"),
        CS: double.parse(map["CircleSize"] ?? "5"),
        OD: double.parse(map["OverallDifficulty"] ?? "5"),
        AR: double.parse(map["ApproachRate"] ?? "5"),
        sliderMultiplier: double.parse(map["SliderMultiplier"]),
        sliderTickRate: double.parse(map["SliderTickRate"]),
      );

  const BeatmapDifficulty.empty()
    : this._(
        HP: 0,
        CS: 5,
        OD: 5,
        AR: 5,
        sliderMultiplier: 1,
        sliderTickRate: 1,
      );

  const BeatmapDifficulty._({
    required this.HP,
    required this.CS,
    required this.OD,
    required this.AR,
    required this.sliderMultiplier,
    required this.sliderTickRate,
  });

  /// HP Drain Rate — controls how quickly health decreases over time.
  final double HP;

  /// Circle Size — determines the radius of hit circles and slider heads.
  final double CS;

  /// Overall Difficulty — tightens the timing windows for hit judgements.
  final double OD;

  /// Approach Rate — controls how long before the hit time objects appear.
  final double AR;

  /// Base velocity multiplier for sliders, in hundreds of osu! pixels per beat.
  final double sliderMultiplier;

  /// Number of slider ticks per beat.
  final double sliderTickRate;

  /// Time in milliseconds between when an object appears and when it must be hit.
  ///
  /// Custom formula (differs slightly from osu! stable):
  /// - AR ≤ 5 → `1200 + 120 * (5 - AR)`
  /// - AR > 5 → `1200 - 150 * (AR - 5)`
  double get preempt {
    if (AR <= 5) return 1200 + 120 * (5 - AR);
    return 1200 - 150 * (AR - 5);
  }

  /// Time in milliseconds over which an object fades in to full opacity.
  ///
  /// Equal to one third of [preempt].
  double get preemptFullOp => preempt / 3;

  /// Radius of hit circles in playfield pixels.
  double get circleRadius => (54.4 - (4.48 * CS)) * 1.00041;

  /// Per-frame health drain multiplier based on HP.
  double get healthDrain => HP / 100;

  /// Half-width of the 300-point (great) timing window, in milliseconds.
  double get hit300 => 80 - 6 * OD;

  /// Half-width of the 100-point (ok) timing window, in milliseconds.
  double get hit100 => 140 - 8 * OD;

  /// Half-width of the 50-point (meh) timing window, in milliseconds.
  ///
  /// Hits outside this window are registered as misses.
  double get hit50 => 200 - 10 * OD;

  /// Returns a copy of this difficulty with the given fields replaced.
  BeatmapDifficulty copyWith({
    double? HP,
    double? CS,
    double? OD,
    double? AR,
    double? sliderMultiplier,
    double? sliderTickRate,
  }) => BeatmapDifficulty._(
    HP: HP ?? this.HP,
    CS: CS ?? this.CS,
    OD: OD ?? this.OD,
    AR: AR ?? this.AR,
    sliderMultiplier: sliderMultiplier ?? this.sliderMultiplier,
    sliderTickRate: sliderTickRate ?? this.sliderTickRate,
  );
}

/// Audio configuration parsed from the `[General]` section of a `.osu` file.
class BeatmapAudio {
  BeatmapAudio.fromMap(Map<String, dynamic> map, String parentPath)
    : path = '$parentPath/${map["AudioFilename"]}',
      previewTime = int.parse(map["PreviewTime"] ?? "0");

  /// Absolute file path to the audio track.
  final String path;

  /// Timestamp (in milliseconds) where the audio preview starts in menus.
  final int previewTime;

  /// [previewTime] as a [Duration].
  Duration get previewDuration => Duration(milliseconds: previewTime);
}

/// Utility class for parsing combo colors from the `[Colours]` section.
class BeatmapColors {
  /// Parses a list of raw RGBA component lists into [Color] objects.
  static List<Color> fromList(List<List<dynamic>> list) => list.map((raw) {
    final r = int.tryParse(raw.elementAtOrNull(0) ?? "255") ?? 255;
    final g = int.tryParse(raw.elementAtOrNull(1) ?? "255") ?? 255;
    final b = int.tryParse(raw.elementAtOrNull(2) ?? "255") ?? 255;
    final a = double.tryParse(raw.elementAtOrNull(3) ?? "1.0") ?? 1.0;

    return Color.fromRGBO(r, g, b, a);
  }).toList();

  /// Fallback color palette used when the `.osu` file defines no colors.
  static const List<Color> byDefault = [
    Color(0xff00ca00),
    Color(0xff127cff),
    Color(0xfff21839),
    Color(0xffffc000),
  ];
}
