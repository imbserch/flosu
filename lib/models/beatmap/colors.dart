import 'dart:ui';

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
