import 'dart:ui';

/// Represents the bitmask types for osu! hit objects.
enum HitObjectType {
  circle(1),
  slider(2),
  newCombo(4),
  spinner(8),

  hold(1);

  const HitObjectType(this.v);
  final int v;

  /// Extracts the base hit object type from a raw bitmask value.
  ///
  /// Example:
  /// ```dart
  /// var type = HitObjectType.circle.getBaseType(10); // Returns HitObjectType.slider (bit 2 is set)
  /// ```
  HitObjectType getBaseType(int bit) {
    if ((bit & 8) != 0) return HitObjectType.spinner;
    if ((bit & 2) != 0) return HitObjectType.slider;
    if ((bit & 1) != 0) return HitObjectType.circle;

    throw StateError("Type not recognized");
  }

  /// Checks if this specific type is present in the provided bitmask.
  bool existsIn(int bit) => (v & bit) != 0;

  /// Calculates how many combo colors to skip based on the bitmask.
  static int comboSkip(int value) => ((value >> 4) & 7);
}

/// Defines the possible scoring outcomes for a hit.
enum HitResult {
  great(300, Color(0xFF64B5F6)),
  ok(100, Color(0xFF689F38)),
  meh(50, Color(0xFFFFC107)),
  miss(0, Color(0xFFF44336));

  const HitResult(this.value, this.color);
  final int value;
  final Color color;
}

/// The mathematical curve type used for sliders.
enum SliderCurve {
  lineal,
  perfect,
  bezier,
  catmull;

  /// Parses the single-letter code from the .osu file format.
  static SliderCurve parse(String raw) => switch (raw) {
    "L" => .lineal,
    "P" => .perfect,
    "B" => .bezier,
    "C" => .catmull,
    _ => throw StateError("Slider curve not recognized"),
  };
}

//TODO: REPLACE OR REMOVE
/// Represents input keys and their corresponding bitmask values in replays.
enum OsuKey {
  m1([1 << 0, 1 << 2]),
  m2([1 << 1, 1 << 3]),
  smoke([1 << 4]);

  const OsuKey(this.keys);
  final List<int> keys;

  /// Returns a list of OsuKeys currently active in the given bitmask.
  static List<OsuKey> pressed(int bit) =>
      values.where((v) => (v.keys.any((key) => (key & bit != 0)))).toList();
}

/// Bitmask values for gameplay modifiers (Mods) used in osu! Stable.
enum Mod {
  noFail(1),
  easy(2),
  touch(4),
  hidden(8),
  hardRock(16),
  suddenDeath(32),
  doubleTime(64),
  relax(128),
  halfTime(256),
  nightcore(512),
  flashlight(1024),
  autoplay(2048),
  spunOut(4096),
  autopilot(8192), //Originally relax2
  perfect(16384),
  cinema(4194304); //Real name: lastMod

  const Mod(this.v);
  final int v;
}
// 