import 'dart:ui';

import 'package:flosu/models/mods/base.dart';

/// Game loop phases.
enum TickerPhase { input, logic, visual }

/// Bitmask flags for the hit-object type field in the `.osu` file format.
///
/// Multiple flags can be set simultaneously (e.g. a new-combo circle has both
/// [circle] and [newCombo] set). Use [existsIn] to test individual flags.
enum HitObjectType {
  circle(1),
  slider(2),
  newCombo(4),
  spinner(8),

  // osu!mania long-note — shares the circle bitmask but is not used here.
  hold(1);

  const HitObjectType(this.v);

  /// The bitmask value for this type.
  final int v;

  /// Extracts the primary hit-object type from a raw bitmask value.
  ///
  /// Checks spinner → slider → circle in order, matching osu! stable behaviour.
  ///
  /// Example:
  /// ```dart
  /// HitObjectType.circle.getBaseType(10); // Returns HitObjectType.slider
  /// ```
  HitObjectType getBaseType(int bit) {
    if ((bit & 8) != 0) return HitObjectType.spinner;
    if ((bit & 2) != 0) return HitObjectType.slider;
    if ((bit & 1) != 0) return HitObjectType.circle;

    throw StateError("Type not recognized");
  }

  /// Returns `true` if this type's flag is set in the given [bit] mask.
  bool existsIn(int bit) => (v & bit) != 0;

  /// Calculates how many combo color slots to skip when a new combo starts.
  ///
  /// Bits 4–6 encode the skip count (0–7) in the hit-object type field.
  static int comboSkip(int value) => ((value >> 4) & 7);
}

/// Scoring outcome for a single hit evaluation.
///
/// Each case carries a [value] (points awarded before bonus multipliers) and a
/// [color] used to tint the hit-error meter bar.
enum HitResult {
  great(300, Color(0xFF64B5F6)),
  ok(100, Color(0xFF689F38)),
  meh(50, Color(0xFFFFC107)),
  miss(0, Color(0xFFF44336));

  const HitResult(this.value, this.color);

  /// Base score value for this result, before combo and difficulty multipliers.
  final int value;

  /// Display color for the hit-error meter.
  final Color color;
}

/// The mathematical curve type used to interpolate a slider's control points.
enum SliderCurve {
  lineal,
  perfect,
  bezier,
  catmull;

  /// Parses the single-letter type code found in the `.osu` file format.
  ///
  /// - `"L"` → [lineal]
  /// - `"P"` → [perfect] (circular arc)
  /// - `"B"` → [bezier]
  /// - `"C"` → [catmull]
  static SliderCurve parse(String raw) => switch (raw) {
    "L" => .lineal,
    "P" => .perfect,
    "B" => .bezier,
    "C" => .catmull,
    _ => throw StateError("Slider curve not recognized"),
  };
}

// TODO: Replace or remove once replay input handling is re-implemented.
/// Input key identifiers and their corresponding bitmask values as used in
/// osu! stable `.osr` replay files.
enum OsuKey {
  m1([1 << 0, 1 << 2]),
  m2([1 << 1, 1 << 3]),
  smoke([1 << 4]);

  const OsuKey(this.keys);

  /// The bitmask values that activate this key.
  final List<int> keys;

  /// Returns all [OsuKey]s whose bitmask is set in [bit].
  static List<OsuKey> pressed(int bit) =>
      values.where((v) => (v.keys.any((key) => (key & bit != 0)))).toList();
}

enum SettingsKey {
  beatmapsPath,
  audioCompensation,
  globalVolume,
  musicVolume,
  osuKeys,
  snakingSlidersEnabled,
  parallaxEnabled,
  backgroundDim,
  backgroundBlur,
  cursorTrailEnabled,
  logsEnabled,
  fpsMonitorEnabled,
}

/// Bitmask values for gameplay modifiers (mods) as encoded in osu! stable files.
///
/// Used when parsing `.osr` replay files via [ConfigurableMod.fromStableBit].
enum Mod {
  noFail(1, 'NF', "No Fail"),
  easy(2, 'EZ', "Easy"),
  touch(4, 'TD', "Touch Device"),
  hidden(8, 'HD', "Hidden"),
  hardRock(16, 'HR', "Hard Rock"),
  suddenDeath(32, 'SD', "Sudden Death"),
  doubleTime(64, 'DT', "Double Time"),
  relax(128, 'RX', "Relax"),
  halfTime(256, 'HT', "Half Time"),
  nightcore(512, 'NC', "Nightcore"),
  flashlight(1024, 'FL', "Flashlight"),
  autoplay(2048, 'AT', "Autoplay"),
  spunOut(4096, 'SO', "Spun Out"),
  autopilot(8192, 'AP', "Autopilot"), // Originally named "Relax2"
  perfect(16384, 'PF', "Perfect"),
  cinema(4194304, 'CN', "Cinema"), // Originally named "LastMod"
  // osu!lazer mods (not recognized in osu!stable)
  daycore(null, 'DC', "Daycore"),
  blinds(null, 'BL', "Blinds"),
  strictTracking(null, 'ST', "Strict Tracking"),
  accuracyChallenge(null, 'AC', "Accuracy Challenge"),
  difficultyAdjust(null, 'DA', "Difficulty Adjust"),
  noScope(null, 'NS', "No Scope"),
  // When osu!lazer detects any stable replay
  classic(null, 'CL', "Classic"),
  // Used when a mod is not recognized.
  unimplemented(null, '??', 'Unimplemented');

  const Mod(this.v, this.acronym, this.name);

  /// The bitmask value for this mod.
  /// This value is null for osu!lazer mods.
  final int? v;

  /// The acronym for this mod, used in file names and short-form display.
  final String acronym;

  /// The name of the mod
  final String name;
}

/// Centralized logger levels.
enum LogLevel { success, debug, info, warning, error }

/// Types of user notifications.
enum NotificationType { info, normal, warning, error }
